import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';

@injectable
class ELM327Service {
  static const List<String> ELM_DEVICE_NAMES = [
    'OBDII', 'OBD', 'ELM327', 'OBD-II', 'OBD Advanced'
  ];

  static const Map<String, String> INIT_COMMANDS = {
    'RESET': 'ATZ',
    'ECHO_OFF': 'ATE0',
    'LINE_FEED_OFF': 'ATL0',
    'HEADERS_OFF': 'ATH0',
    'SPACES_OFF': 'ATS0',
    'SET_PROTOCOL': 'ATSP0', // Auto protocol detection
  };

  static const String SPP_SERVICE_UUID = "0000ffe0-0000-1000-8000-00805f9b34fb";
  static const String SPP_CHARACTERISTIC_UUID = "0000ffe1-0000-1000-8000-00805f9b34fb";

  static const List<String> COMMON_PINS = ["0000", "1234", "6789"];

  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _notificationSubscription;
  final StreamController<String> _dataStreamController = StreamController<String>.broadcast();
  final StreamController<BluetoothConnectionState> _connectionStateController = StreamController<BluetoothConnectionState>.broadcast();

  bool get isConnected => _device != null && _rxCharacteristic != null && _device!.isConnected;
  Stream<String> get dataStream => _dataStreamController.stream;
  Stream<BluetoothConnectionState> get connectionState => _connectionStateController.stream;

  Future<List<BluetoothDevice>> scanForDevices({Duration timeout = const Duration(seconds: 10)}) async {
    List<BluetoothDevice> elmDevices = [];

    try {
      if (!await FlutterBluePlus.isAvailable) {
        throw Exception('Bluetooth is not available on this device');
      }
      if (!await FlutterBluePlus.isOn) {
        throw Exception('Bluetooth is turned off');
      }

      print('Starting scan for OBD devices...');
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      await for (final result in FlutterBluePlus.scanResults) {
        for (final r in result) {
          final deviceName = r.device.name?.toUpperCase() ?? '';
          if (deviceName.isNotEmpty && ELM_DEVICE_NAMES.any((name) => deviceName.contains(name))) {
            if (!elmDevices.contains(r.device)) {
              print('Found OBD device: <span class="math-inline">\{r\.device\.name\} \(</span>{r.device.id})');
              elmDevices.add(r.device);
            }
          }
        }
      }
    } catch (e) {
      print('Error scanning for devices: $e');
      rethrow;
    } finally {
      await FlutterBluePlus.stopScan();
      print('Scan completed. Found ${elmDevices.length} OBD devices');
    }

    return elmDevices;
  }

Future<bool> connectToDevice(BluetoothDevice device, {Duration timeout = const Duration(seconds: 15)}) async {
    _device = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _connectionStateSubscription?.cancel();
    _notificationSubscription?.cancel();
    _connectionStateController.add(BluetoothConnectionState.connecting);

    try {
      print('Attempting to connect to ${device.name} (${device.id})...');
      _setupConnectionStateMonitor(device);

      // Check bond state
      BluetoothBondState bondState = await device.bondState.first;
      if (bondState != BluetoothBondState.bonded) {
        print('Device ${device.name} is not bonded (state: $bondState). Requesting bonding...');
        try {
          await device.pair(); // Initiate system pairing UI
          bondState = await device.bondState.first;
          if (bondState == BluetoothBondState.bonded) {
            print('Successfully bonded with device.');
          } else {
            print('Bonding process did not result in a bonded state (state: $bondState).');
          }
        } catch (e) {
          print('Error during bonding: $e');
        }
      } else {
        print('Device ${device.name} is already bonded.');
      }

      await device.connect(autoConnect: false, timeout: timeout);
      _device = device;
      _connectionStateController.add(BluetoothConnectionState.connected);
      print('Connected to ${device.name}');

      print('Discovering services...');
      final services = await device.discoverServices();
      print('Found ${services.length} services');

      // Function to check characteristic properties
      bool hasWrite(BluetoothCharacteristic c) => c.properties.write || c.properties.writeWithoutResponse;
      bool hasReadNotify(BluetoothCharacteristic c) => c.properties.notify || c.properties.indicate || c.properties.read;

      // Prioritize finding the standard SPP characteristics
      for (final service in services) {
        print('Checking service: ${service.uuid}');
        if (service.uuid.toString().toLowerCase() == SPP_SERVICE_UUID.toLowerCase()) {
          print('Found potential SPP service');
          for (final characteristic in service.characteristics) {
            print('Checking characteristic: ${characteristic.uuid}, properties: write=${characteristic.properties.write}, writeWithoutResponse=${characteristic.properties.writeWithoutResponse}, notify=${characteristic.properties.notify}, indicate=${characteristic.properties.indicate}, read=${characteristic.properties.read}');
            if (_txCharacteristic == null && characteristic.uuid.toString().toLowerCase() == SPP_CHARACTERISTIC_UUID.toLowerCase() && hasWrite(characteristic)) {
              _txCharacteristic = characteristic;
              print('Found TX characteristic (SPP): ${_txCharacteristic!.uuid}');
            }
            if (_rxCharacteristic == null && characteristic.uuid.toString().toLowerCase() == SPP_CHARACTERISTIC_UUID.toLowerCase() && hasReadNotify(characteristic)) {
              _rxCharacteristic = characteristic;
              print('Found RX characteristic (SPP): ${_rxCharacteristic!.uuid}');
              await _setupNotifications();
            }
          }
          if (_txCharacteristic != null && _rxCharacteristic != null) break; // Found both, no need to continue
        }
      }

      // If standard SPP not found, look for any suitable characteristics
      if (_txCharacteristic == null || _rxCharacteristic == null) {
        print('Standard SPP characteristics not found, looking for generic ones...');
        for (final service in services) {
          print('Checking service: ${service.uuid}');
          for (final characteristic in service.characteristics) {
            print('Checking characteristic: ${characteristic.uuid}, properties: write=${characteristic.properties.write}, writeWithoutResponse=${characteristic.properties.writeWithoutResponse}, notify=${characteristic.properties.notify}, indicate=${characteristic.properties.indicate}, read=${characteristic.properties.read}');
            if (_txCharacteristic == null && hasWrite(characteristic)) {
              _txCharacteristic = characteristic;
              print('Found suitable TX characteristic: ${_txCharacteristic!.uuid}');
            }
            if (_rxCharacteristic == null && hasReadNotify(characteristic)) {
              _rxCharacteristic = characteristic;
              print('Found suitable RX characteristic: ${_rxCharacteristic!.uuid}');
              await _setupNotifications();
            }
            if (_txCharacteristic != null && _rxCharacteristic != null) break;
          }
          if (_txCharacteristic != null && _rxCharacteristic != null) break;
        }
      }

      if (_txCharacteristic != null && _rxCharacteristic != null) {
        print('TX and RX characteristics found (${_txCharacteristic!.uuid}, ${_rxCharacteristic!.uuid}), initializing ELM327');
        return await initializeELM();
      } else {
        final error = 'Failed to find necessary characteristics. TX found: ${_txCharacteristic != null}, RX found: ${_rxCharacteristic != null}';
        print(error);
        await disconnect();
        throw Exception(error);
      }
    } catch (e) {
      _connectionStateController.add(BluetoothConnectionState.disconnected);
      print('Connection error: $e');
      await disconnect();
      return false;
    }
  }
  void _setupConnectionStateMonitor(BluetoothDevice device) {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((state) {
      print('Connection state of <span class="math-inline">\{device\.name\} \(</span>{device.id}) changed: $state');
      _connectionStateController.add(state);
      if (state == BluetoothConnectionState.disconnected && _device?.id == device.id) {
        print('Device <span class="math-inline">\{device\.name\} \(</span>{device.id}) disconnected unexpectedly');
        _cleanupConnection();
      }
    });
  }

  Future<void> _setupNotifications() async {
    try {
      if (_rxCharacteristic == null) return;

      await _notificationSubscription?.cancel();

      await _rxCharacteristic!.setNotifyValue(true);
      print('Notifications enabled for RX characteristic ${_rxCharacteristic!.uuid}');

      _notificationSubscription = _rxCharacteristic!.lastValueStream.listen((value) {
        if (value.isNotEmpty) {
          final response = String.fromCharCodes(value).trim();
          print('Received data on ${_rxCharacteristic!.uuid}: $response');
          _dataStreamController.add(response);
        }
      }, onError: (error) {
        print('Notification error on ${_rxCharacteristic!.uuid}: $error');
      });
    } catch (e) {
      print('Error setting up notifications for ${_rxCharacteristic?.uuid}: $e');
    }
  }

  Future<bool> initializeELM() async {
    try {
      print('Initializing ELM327...');
      for (final entry in INIT_COMMANDS.entries) {
        final command = entry.value;
        final key = entry.key;
        print('Sending command: $key ($command)');
        final response = await sendCommand(command);
        print('Response to $key: $response');

        if (!response.contains('OK') && !response.contains('ELM') && !response.contains('>') && !response.contains('ATZ')) {
          print('Failed to initialize ELM with command $key. Response: $response');
          return false;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
      print('ELM327 initialized successfully');
      return true;
    } catch (e) {
      print('ELM initialization error: $e');
      return false;
    }
  }

  Future<String> sendCommand(String command, {Duration timeout = const Duration(seconds: 3)}) async {
    if (_txCharacteristic == null) {
      throw Exception('TX characteristic not available');
    }

    final completer = Completer<String>();
    StreamSubscription? subscription;
    Timer? timer;

    try {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          subscription?.cancel();
          completer.completeError('Command timeout: $command');
        }
      });

      final responseBuffer = <int>[];
      subscription = _dataStreamController.stream.listen((response) {
        responseBuffer.addAll(response.codeUnits);
        final fullResponse = String.fromCharCodes(responseBuffer);
        print('Received chunk for command "$command": $response, full buffer: "$fullResponse"');

        if (fullResponse.contains('>') || fullResponse.contains('OK') || fullResponse.contains('ERROR') || fullResponse.contains('?')) {
          if (!completer.isCompleted) {
            timer?.cancel();
            subscription?.cancel();
            completer.complete(fullResponse.trim());
          }
        }
      }, onError: (e) {
        if (!completer.isCompleted) {
          timer?.cancel();
          subscription?.cancel();
          completer.completeError('Error receiving response for command "$command": $e');
        }
      });

      // Clear any buffered data before sending command (attempt)
      try {
        final readValue = await _rxCharacteristic?.read();
        if (readValue != null && readValue.isNotEmpty) {
          print('Cleared buffered data: ${String.fromCharCodes(readValue).trim()}');
        }
      } catch (e) {
        print('Error clearing buffer: $e (ignoring)');
      }

      print('Sending command: $command\\r on ${_txCharacteristic!.uuid}');
      await _txCharacteristic!.write(
        Uint8List.fromList('$command\r'.codeUnits),
        withoutResponse: _txCharacteristic!.properties.writeWithoutResponse,
      );

      // Fallback for devices that don't send notifications immediately
      if (!_rxCharacteristic!.properties.notify && !_rxCharacteristic!.properties.indicate) {
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final response = await _rxCharacteristic!.read();
          final manualResponse = String.fromCharCodes(response).trim();
          if (!completer.isCompleted) {
            timer?.cancel();
            subscription?.cancel();
            completer.complete(manualResponse);
          }
        } catch (e) {
          print('Error during manual read for command "$command": $e');
          if (!completer.isCompleted) {
            timer?.cancel();
            subscription?.cancel();
            completer.completeError('Manual read error: $e');
          }
        }
      }

      return await completer.future;
    } catch (e) {
      print('Command error for "$command": $e');
      completer.completeError(e);
      rethrow;
    } finally {
      timer?.cancel();
      subscription?.cancel();
    }
  }

  Future<int?> getEngineRPM() async {
    try {
      final response = await sendCommand('010C');
      if (response.contains('41 0C') || response.contains('410C')) {
        final parts = response.replaceAll(' ', '').split('\r').where((s) => s.contains('410C')).first.substring(4).trim().split('');
        if (parts.length >= 4) {
          final hexValue = parts.sublist(0, 4).join();
          final value = int.parse(hexValue, radix: 16);
          return value ~/ 4;
        }
      }
      print('Unable to parse RPM from response: $response');
      return null;
    } catch (e) {
      print('Error getting RPM: $e');
      return null;
    }
  }

  Future<List<String>> getErrorCodes() async {
    try {
      final response = await sendCommand('03');
      final dtcCodes = <String>[];
      if (!response.contains('NO DATA') && !response.contains('ERROR')) {
        final lines = response.split('\r');
        for (final line in lines) {
          if (line.startsWith('43')) {
            final data = line.substring(2).replaceAll(' ', '');
            for (int i = 0; i < data.length; i += 4) {
              if (i + 4 <= data.length) {
                final dtcHex = data.substring(i, i + 4);
                if (dtcHex != '0000') {
                  final dtcCode = _convertHexToDTC(dtcHex);
                  if (dtcCode.isNotEmpty) {
                    dtcCodes.add(dtcCode);
                  }
                }
              }
            }
          }
        }
      }
      return dtcCodes;
    } catch (e) {
      print('Error getting DTCs: $e');
      return [];
    }
  }

  String _convertHexToDTC(String hex) {
    if (hex.length != 4) return '';
    String firstChar = '';
    switch (hex[0]) {
      case '0': firstChar = 'P0'; break;
      case '1': firstChar = 'P1'; break;
      case '2': firstChar = 'P2'; break;
      case '3': firstChar = 'P3'; break;
      case '4': firstChar = 'C0'; break;
      case '5': firstChar = 'C1'; break;
      case '6': firstChar = 'C2'; break;
      case '7': firstChar = 'C3'; break;
      case '8': firstChar = 'B0'; break;
      case '9': firstChar = 'B1'; break;
      case 'A': firstChar = 'B2'; break;
      case 'B': firstChar = 'B3'; break;
      case 'C': firstChar = 'U0'; break;
      case 'D': firstChar = 'U1'; break;
      case 'E': firstChar = 'U2'; break;
      case 'F': firstChar = 'U3'; break;
      default: return '';
    }
    return firstChar + hex.substring(1);
  }

  Future<void> disconnect() async {
    try {
      if (_device != null) {
        print('Disconnecting from ${_device!.name} (${_device!.id})...');
        await _device!.disconnect();
        print('Disconnected from ${_device!.name} (${_device!.id})');
      }
    } catch (e) { 
      print('Error disconnecting: $e');
    } finally {
      _cleanupConnection();
    }
  }
  void _cleanupConnection() {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _device = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _connectionStateController.add(BluetoothConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _dataStreamController.close();
    _connectionStateController.close();
  }
}

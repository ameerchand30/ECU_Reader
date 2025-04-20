import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BluetoothService {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  static const String OBD_SERVICE_UUID = "0000FFF0-0000-1000-8000-00805F9B34FB";
  static const String WRITE_CHARACTERISTIC_UUID = "0000FFF2-0000-1000-8000-00805F9B34FB";
  static const String READ_CHARACTERISTIC_UUID = "0000FFF1-0000-1000-8000-00805F9B34FB";

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _device = device;
      
      List<BluetoothService> services = await device.discoverServices();
      var ecuService = services.firstWhere(
        (s) => s.uuid.toString() == OBD_SERVICE_UUID
      );
      
      _writeCharacteristic = ecuService.characteristics.firstWhere(
        (c) => c.uuid.toString() == WRITE_CHARACTERISTIC_UUID
      );
      
      _readCharacteristic = ecuService.characteristics.firstWhere(
        (c) => c.uuid.toString() == READ_CHARACTERISTIC_UUID
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<int>> sendCommand(List<int> command) async {
    if (_writeCharacteristic == null || _readCharacteristic == null) {
      throw Exception('Device not connected');
    }

    await _writeCharacteristic!.write(command);
    final response = await _readCharacteristic!.read();
    return response;
  }
}
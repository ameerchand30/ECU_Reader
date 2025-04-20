import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

@injectable
class ObdBluetoothService {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? _device; // Changed to private variable with underscore
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;

  static const String OBD_SERVICE_UUID = "0000FFF0-0000-1000-8000-00805F9B34FB";
  static const String WRITE_CHARACTERISTIC_UUID = "0000FFF2-0000-1000-8000-00805F9B34FB";
  static const String READ_CHARACTERISTIC_UUID = "0000FFF1-0000-1000-8000-00805F9B34FB";

  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _device = device; // Correct assignment to class variable
      
      List<BluetoothService> services = await device.discoverServices();
      
      // Add error handling for service discovery
      try {
        var ecuService = services.firstWhere(
          (s) => s.uuid.toString() == OBD_SERVICE_UUID,
          orElse: () => throw Exception('OBD service not found'),
        );
        
        _writeCharacteristic = ecuService.characteristics.firstWhere(
          (c) => c.uuid.toString() == WRITE_CHARACTERISTIC_UUID,
          orElse: () => throw Exception('Write characteristic not found'),
        );
        
        _readCharacteristic = ecuService.characteristics.firstWhere(
          (c) => c.uuid.toString() == READ_CHARACTERISTIC_UUID,
          orElse: () => throw Exception('Read characteristic not found'),
        );
        
        return true;
      } catch (e) {
        print('Service discovery error: $e');
        await device.disconnect();
        return false;
      }
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }
    
    Future<List<int>> sendCommand(List<int> command) async {
      if (_writeCharacteristic == null || _readCharacteristic == null) {
        throw Exception('Device not connected or characteristics not found');
      }
  
      try {
        await _writeCharacteristic!.write(command, withoutResponse: true);
        await Future.delayed(Duration(milliseconds: 100)); // Wait for response
        List<int> response = await _readCharacteristic!.read();
        return response;
      } catch (e) {
        print('Error sending command: $e');
        throw e;
      }
    }
  
    Future<void> disconnect() async {
      if (_device != null) {
        await _device!.disconnect();
      }
    }
}


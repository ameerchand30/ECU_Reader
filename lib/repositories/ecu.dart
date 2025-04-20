import 'dart:async';
import 'package:injectable/injectable.dart';
import '../domain/ecu_error.dart';
import '../../core/bluetooth/bluetooth_service.dart';

@injectable
class ECURepository {
  final BluetoothService _bluetoothService;
  
  ECURepository(this._bluetoothService);

  // Command codes
  static const List<int> READ_ERRORS_COMMAND = [0x03, 0x03];
  static const List<int> CLEAR_ERRORS_COMMAND = [0x04, 0x04];

  Future<List<ECUError>> readErrors() async {
    try {
      final response = await _bluetoothService.sendCommand(READ_ERRORS_COMMAND);
      return _parseErrorResponse(response);
    } catch (e) {
      throw Exception('Failed to read ECU errors: $e');
    }
  }

  Future<bool> clearErrors() async {
    try {
      final response = await _bluetoothService.sendCommand(CLEAR_ERRORS_COMMAND);
      return response[0] == 0x44; // Success response code
    } catch (e) {
      throw Exception('Failed to clear ECU errors: $e');
    }
  }

  List<ECUError> _parseErrorResponse(List<int> response) {
    List<ECUError> errors = [];
    
    for (var i = 0; i < response.length; i += 4) {
      if (i + 3 >= response.length) break;
      
      final code = response.sublist(i, i + 2);
      final description = _getErrorDescription(code);
      final severity = _getErrorSeverity(code);
      
      errors.add(ECUError(
        code: '${code[0].toRadixString(16).padLeft(2, '0')}${code[1].toRadixString(16).padLeft(2, '0')}',
        description: description,
        severity: severity,
        timestamp: DateTime.now(),
      ));
    }
    
    return errors;
  }

  String _getErrorDescription(List<int> code) {
    // Add your error code mappings here
    return 'Error ${code[0].toRadixString(16)}${code[1].toRadixString(16)}';
  }

  String _getErrorSeverity(List<int> code) {
    // Add your severity logic here
    return 'HIGH';
  }
}
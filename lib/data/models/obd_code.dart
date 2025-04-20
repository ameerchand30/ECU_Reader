class OBDCode {
  final String code;
  final String description;
  final String severity;
  final DateTime timestamp;

  OBDCode({
    required this.code,
    required this.description,
    required this.severity,
    required this.timestamp,
  });

  factory OBDCode.fromResponse(String response) {
    // Parse typical OBD response format
    // Example: "43 01 33 00 00 00 00" -> P0133
    final code = response.substring(0, 4);
    return OBDCode(
      code: 'P$code',
      description: getDescriptionForCode(code),
      severity: getSeverityForCode(code),
      timestamp: DateTime.now(),
    );
  }

  static String getDescriptionForCode(String code) {
    // Add your DTC code database here
    final dtcDatabase = {
      '0133': 'O2 Sensor Circuit Slow Response',
      // Add more codes...
    };
    return dtcDatabase[code] ?? 'Unknown Error Code';
  }

  static String getSeverityForCode(String code) {
    if (code.startsWith('P0')) return 'Generic';
    if (code.startsWith('P1')) return 'Manufacturer Specific';
    if (code.startsWith('P2')) return 'Generic';
    if (code.startsWith('P3')) return 'Generic';
    return 'Unknown';
  }
}
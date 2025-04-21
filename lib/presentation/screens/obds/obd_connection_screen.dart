import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../services/obd_bluetooth_service.dart';
// import '../../../ecu_page.dart';
import '../../../utils/ui.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ecu_bloc.dart';

class OBDConnectionScreen extends StatefulWidget {
  @override
  _OBDConnectionScreenState createState() => _OBDConnectionScreenState();
}

class _OBDConnectionScreenState extends State<OBDConnectionScreen> {
  final ObdBluetoothService _bluetoothService = GetIt.instance<ObdBluetoothService>();
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    
    try {
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _devices = results
              .where((r) => r.device.name.toLowerCase().contains('obd'))
              .map((r) => r.device)
              .toList();
        });
      });
      
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final connected = await _bluetoothService.connectToDevice(device);
      if (connected && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => GetIt.instance<ECUBloc>(),
              child:  ECUPage(),
            ),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to connect to OBD device')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect OBD Device'),
        actions: [
          if (!_isScanning)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startScan,
            ),
        ],
      ),
      body: _isScanning
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  title: Text(device.name),
                  subtitle: Text(device.id.id),
                  trailing: const Icon(Icons.bluetooth),
                  onTap: () => _connectToDevice(device),
                );
              },
            ),
    );
  }
}
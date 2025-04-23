import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:toastification/toastification.dart';
import '../../../services/obd_bluetooth_service.dart';
// import '../../../ecu_page.dart';
import '../../../utils/ui.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ecu_bloc.dart';
import '../../../services/elm327_service.dart';


class OBDConnectionScreen extends StatefulWidget {
  @override
  _OBDConnectionScreenState createState() => _OBDConnectionScreenState();
}

class _OBDConnectionScreenState extends State<OBDConnectionScreen> {
  // final ObdBluetoothService _bluetoothService = GetIt.instance<ObdBluetoothService>();
  final ELM327Service _elmService = GetIt.instance<ELM327Service>();
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    toastification.show(
      context: context, // You need to provide the context if not using context-free
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text('Scanning...'),
      description: Text('Looking for ELM327 OBD devices'),
      autoCloseDuration: const Duration(seconds: 2),
      showProgressBar: true,
      backgroundColor: Colors.blue,
    );

    setState(() => _isScanning = true);
    
    try {
      _devices = await _elmService.scanForDevices();
    } catch (e) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text('Error scanning for devices'),
        description: Text(e.toString()),
      );
    } finally {
      setState(() => _isScanning = false);
    }
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text('Scan complete'),
      description: Text('${_devices.length} devices found'),
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final connected = await _elmService.connectToDevice(device);
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
          SnackBar(content: Text('Failed to initialize ELM327 device')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Connection Error: $e')),
      );
    }
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text('Connected to OBD device'),
      description: Text('You can now read ECU errors'),
    );
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
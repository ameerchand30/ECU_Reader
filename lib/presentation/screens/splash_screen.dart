import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_it/get_it.dart';
import '../../utils/ui.dart';
import '../../bloc/ecu_bloc.dart';
import '../screens/obds/obd_connection_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Request permissions
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.location.request();

    // Navigate to main screen
    if (mounted) {
      //either to move to the ECUPage
/*       Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GetIt.instance<ECUBloc>(),
            child:  ECUPage(),
          ),
        ),
      ); */
      // or to move to the OBDConnectionScreen
/*       Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => GetIt.instance<ECUBloc>(),
            child: OBDConnectionScreen(),
          ),
        ),
      ); */
      // or to move to the OBDConnectionScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OBDConnectionScreen()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing...'),
          ],
        ),
      ),
    );
  }
}
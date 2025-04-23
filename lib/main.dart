import 'package:ecu_reader/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'services/obd_bluetooth_service.dart';
import 'services/elm327_service.dart';
import 'repositories/ecu_repository.dart';
import 'bloc/ecu_bloc.dart';
import 'utils/ui.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // Register services
  getIt.registerLazySingleton<ObdBluetoothService>(() => ObdBluetoothService());
  getIt.registerLazySingleton<ELM327Service>(() => ELM327Service());
  
  // Register repositories
  getIt.registerLazySingleton<ECURepository>(
    () => ECURepository(getIt<ObdBluetoothService>())
  );
  
  // Register blocs
  getIt.registerFactory<ECUBloc>(
    () => ECUBloc(getIt<ECURepository>())
  );
  
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECU Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => getIt<ECUBloc>(),
        // child:  ECUPage(),
         child: SplashScreen()
      ),
    );
  }
}
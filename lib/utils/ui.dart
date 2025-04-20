import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ecu_bloc.dart';
import '../models/ecu_error.dart';

class ECUPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ECU Error Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ECUBloc>().add(const ECUEvent.readErrors());
            },
          ),
        ],
      ),
      body: BlocBuilder<ECUBloc, ECUState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const Center(
              child: Text('Press refresh to read ECU errors'),
            ),
            loading: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
            loaded: (state) => ErrorList(errors: state.errors),
            cleared: (_) => const Center(
              child: Text('All errors cleared successfully'),
            ),
            error: (state) => Center(
              child: Text('Error: ${state.message}'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<ECUBloc>().add(const ECUEvent.clearErrors());
        },
        child: const Icon(Icons.delete),
      ),
    );
  }
}

class ErrorList extends StatelessWidget {
  final List<ECUError> errors;

  const ErrorList({Key? key, required this.errors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: errors.length,
      itemBuilder: (context, index) {
        final error = errors[index];
        return ListTile(
          title: Text('Error Code: ${error.code}'),
          subtitle: Text(error.description),
          trailing: Text(
            error.severity,
            style: TextStyle(
              color: error.severity == 'HIGH' ? Colors.red : Colors.orange,
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';

class AddVideo extends StatelessWidget {
  const AddVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        // Listen to settings state changes
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Add New Video')),
          body: const Center(child: Text('Add Video Screen Content')),
        );
      },
    );
  }
}

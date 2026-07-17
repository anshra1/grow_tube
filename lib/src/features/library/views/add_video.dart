import 'package:flutter/material.dart';

class AddVideo extends StatelessWidget {
  const AddVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Video'),
      ),
      body: const Center(
        child: Text('Add Video Screen Content'),
      ),
    );
  }
}

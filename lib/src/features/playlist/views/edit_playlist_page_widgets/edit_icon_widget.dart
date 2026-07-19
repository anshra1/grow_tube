import 'package:flutter/material.dart';

class EditIcon extends StatelessWidget {
  const EditIcon({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.edit, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

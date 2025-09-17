import 'package:flutter/material.dart';

class ResetButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ResetButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        ),
        child: const Text('Reset All Settings to Default'),
      ),
    );
  }
}

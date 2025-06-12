import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerTile extends StatelessWidget {
  final String title;
  final Color? color;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onColorCleared;

  const ColorPickerTile({
    super.key,
    required this.title,
    this.color,
    required this.onColorChanged,
    required this.onColorCleared,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: onColorCleared,
              tooltip: 'Reset to default',
            ),
          CircleAvatar(
            backgroundColor: color ?? Theme.of(context).colorScheme.primary,
            radius: 14,
          ),
        ],
      ),
      onTap: () => _showColorPickerDialog(context),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color ?? Colors.blue,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

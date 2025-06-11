import 'package:flutter/material.dart';

class MapEditorTile extends StatefulWidget {
  final String title;
  final Map<String, String> preferences;
  final ValueChanged<Map<String, String>> onChanged;

  const MapEditorTile({
    super.key,
    required this.title,
    required this.preferences,
    required this.onChanged,
  });

  @override
  State<MapEditorTile> createState() => _MapEditorTileState();
}

class _MapEditorTileState extends State<MapEditorTile> {
  late Map<String, String> _localPrefs;
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localPrefs = Map.of(widget.preferences);
  }

  @override
  void didUpdateWidget(covariant MapEditorTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.preferences != oldWidget.preferences) {
      _localPrefs = Map.of(widget.preferences);
    }
  }

  void _addOrUpdate() {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();
    if (key.isNotEmpty) {
      setState(() => _localPrefs[key] = value);
      widget.onChanged(_localPrefs);
      _keyController.clear();
      _valueController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _remove(String key) {
    setState(() => _localPrefs.remove(key));
    widget.onChanged(_localPrefs);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title),
      subtitle: Text('${_localPrefs.length} entries'),
      children: [
        for (final entry in _localPrefs.entries)
          ListTile(
            dense: true,
            title: Text(entry.key),
            subtitle: Text(entry.value),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => _remove(entry.key),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _keyController,
                  decoration: const InputDecoration(labelText: 'Key'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _addOrUpdate,
              ),
            ],
          ),
        )
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../core/models/mining_pool.dart';

class AddPoolDialog extends StatefulWidget {
  const AddPoolDialog({super.key});

  @override
  State<AddPoolDialog> createState() => _AddPoolDialogState();
}

class _AddPoolDialogState extends State<AddPoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _serverNameController = TextEditingController();
  final _serverUrlController = TextEditingController();

  String? _validateWebSocketUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter server URL';
    }

    // Check if URL starts with ws:// or wss://
    if (!value.startsWith('ws://') && !value.startsWith('wss://')) {
      return 'URL must start with ws:// or wss://';
    }

    // Try to parse the URL
    try {
      final uri = Uri.parse(value);
      if (uri.host.isEmpty) {
        return 'Invalid host';
      }
    } catch (e) {
      return 'Invalid URL format';
    }

    return null;
  }

  @override
  void dispose() {
    _serverNameController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Pool'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _serverNameController,
              decoration: const InputDecoration(
                labelText: 'Server Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., My Pool Server',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter server name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 400,
              child: TextFormField(
                controller: _serverUrlController,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  border: OutlineInputBorder(),
                  helperText: 'WebSocket URL (ws:// or wss://)',
                ),
                validator: _validateWebSocketUrl,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final server = MiningPoolServer(
                name: _serverNameController.text,
                url: _serverUrlController.text,
              );
              Navigator.of(context).pop(server);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

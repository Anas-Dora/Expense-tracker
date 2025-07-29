import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final VoidCallback clearData;

  const DeleteConfirmationDialog({super.key, required this.clearData});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff272a2f),
      title: Text('Bestätigen', style: TextStyle(color: Color(0xffe1e2e8))),
      content: Text(
        'Möchtest du wirklich alle Ausgaben löschen?',
        style: TextStyle(color: Color(0xffe1e2e8)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Abbrechen',
            style: TextStyle(color: Color(0xffe1e2e8)),
          ),
        ),
        TextButton(
          onPressed: () {
            clearData();
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Löschen'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class KategorieFilterDialog extends StatelessWidget {
  final List<String> ausgewaehlteKategorien;
  final void Function(List<String>) onSelected;

  const KategorieFilterDialog({
    required this.ausgewaehlteKategorien,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<String> selected = List.from(ausgewaehlteKategorien);

    return AlertDialog(
      title: Text('Kategorien auswählen'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // hier CheckboxListTile-Liste
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onSelected(selected);
            Navigator.pop(context);
          },
          child: Text('Fertig'),
        ),
      ],
    );
  }
}

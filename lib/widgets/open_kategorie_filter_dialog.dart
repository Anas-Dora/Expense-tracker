import 'package:flutter/material.dart';

class OpenKategorieFilterDialog extends StatelessWidget {
  final List<String> kategorien;
  final List<String> ausgewaehlteKategorien;
  final Function(Set<String>) onFilterSelected;

  const OpenKategorieFilterDialog({
    super.key,
    required this.kategorien,
    required this.ausgewaehlteKategorien,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    Set<String> tempKategorien = Set.from(ausgewaehlteKategorien);

    return AlertDialog(
      backgroundColor: const Color(0xff191c20),
      title: const Text(
        'Kategorien auswählen',
        style: TextStyle(color: Color(0xFFE1E2E8)),
      ),
      content: StatefulBuilder(
        builder: (context, setStateDialog) {
          return SingleChildScrollView(
            child: Column(
              children:
                  kategorien.where((kategorie) => kategorie != 'Alle').map((
                    kategorie,
                  ) {
                    final isSelected = tempKategorien.contains(kategorie);
                    return Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.white),
                      child: CheckboxListTile(
                        activeColor: const Color(0xffA0CAFD),
                        checkColor: const Color(0xff003258),
                        title: Text(
                          kategorie,
                          style: const TextStyle(color: Color(0xFFE1E2E8)),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setStateDialog(() {
                            if (value == true) {
                              tempKategorien.add(kategorie);
                            } else {
                              tempKategorien.remove(kategorie);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text(
            'Fertig',
            style: TextStyle(color: Color(0xffa0cafd)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onFilterSelected(tempKategorien);
          },
        ),
      ],
    );
  }
}

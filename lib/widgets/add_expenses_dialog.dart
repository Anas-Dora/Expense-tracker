import 'package:expenditure/data/ausgabe.dart';
import 'package:expenditure/utils/euro_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class AddExpensesDialog extends StatefulWidget {
  final List<String> kategorien;

  const AddExpensesDialog({super.key, required this.kategorien});

  @override
  State<AddExpensesDialog> createState() => _AddExpensesDialogState();
}

class _AddExpensesDialogState extends State<AddExpensesDialog> {
  final _betragController = TextEditingController();
  final _beschreibungController = TextEditingController();
  String? _gewaehlteKategorie;

  @override
  void initState() {
    super.initState();
    _gewaehlteKategorie =
        widget.kategorien.isNotEmpty ? widget.kategorien.first : null;

    _betragController.text = "0.00";
    _gewaehlteKategorie = widget.kategorien.firstWhere(
      (k) => k != 'Alle',
      orElse: () => '',
    );
  }

  @override
  void dispose() {
    _betragController.dispose();
    _beschreibungController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff272a2f),
      title: Text('Neue Ausgabe', style: TextStyle(color: Color(0xffe1e2e8))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _betragController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              EuroFormatter(),
            ],
            style: TextStyle(color: Color(0xffe1e2e8)),
            cursorColor: Color(0xffa0cafd),
            decoration: InputDecoration(
              suffixText: '€ ',
              suffixStyle: TextStyle(color: Color(0xffe1e2e8)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffa0cafd)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffC3C7CF)),
              ),
              labelText: 'Betrag',
              labelStyle: TextStyle(color: Color(0xffe1e2e8)),
              focusColor: Color(0xffa0cafd),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _beschreibungController,
            style: TextStyle(color: Color(0xffe1e2e8)),
            cursorColor: Color(0xffa0cafd),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffa0cafd)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffC3C7CF)),
              ),
              labelText: 'Beschreibung',
              labelStyle: TextStyle(color: Color(0xffe1e2e8)),
              focusColor: Color(0xffa0cafd),
            ),
          ),
          const SizedBox(height: 10),
          Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffe1e2e8)),
                ),
              ),
            ),
            child: DropdownMenu<String>(
              width: 300,
              trailingIcon: Icon(
                Icons.arrow_drop_down,
                color: Color(0xffe1e2e8),
              ),
              textStyle: TextStyle(color: Color(0xffe1e2e8)),
              menuStyle: MenuStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                  Color(0xff272a2f),
                ),
              ),
              initialSelection: _gewaehlteKategorie,

              onSelected: (value) {
                if (value != null) {
                  setState(() {
                    _gewaehlteKategorie = value;
                  });
                }
              },
              dropdownMenuEntries:
                  widget.kategorien
                      .where((k) => k != 'Alle')
                      .map(
                        (k) => DropdownMenuEntry(
                          value: k,
                          label: k,
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                              Color(0xffe1e2e8),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Abbrechen',
            style: TextStyle(color: Color(0xffa0cafd)),
          ),
        ),
        FilledButton(
          onPressed: () {
            final betrag = double.tryParse(_betragController.text);
            final beschreibung = _beschreibungController.text;
            final kategorie = _gewaehlteKategorie;

            if (betrag != null &&
                beschreibung.isNotEmpty &&
                kategorie != null) {
              final ausgabebox = Hive.box<Ausgabe>('ausgaben');
              final neueAusgabe = Ausgabe(
                betrag,
                beschreibung,
                kategorie,
                DateTime.now(),
              );
              ausgabebox.add(neueAusgabe);
              Navigator.pop(context, neueAusgabe);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bitte Betrag, Beschreibung und Kategorie eingeben.',
                  ),
                ),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Color(0xffa0cafd)),
            foregroundColor: WidgetStatePropertyAll<Color>(Color(0xff003258)),
          ),
          child: const Text('Hinzufügen'),
        ),
      ],
    );
  }
}

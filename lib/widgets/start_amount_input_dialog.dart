import 'package:expenditure/data/betrag.dart';
import 'package:expenditure/utils/euro_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class StartAmountInputDialog extends StatefulWidget {
  final VoidCallback updateStateExtern;

  const StartAmountInputDialog({super.key, required this.updateStateExtern});

  @override
  State<StartAmountInputDialog> createState() => _StartAmountInputDialogState();
}

class _StartAmountInputDialogState extends State<StartAmountInputDialog> {
  final _controller = TextEditingController();
  var currentAmount = 00.0;
  bool idAdd = false;

  @override
  void initState() {
    super.initState();
    _controller.text = "0.00";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF272A2F),
      title: Text(
        'Betrag festlegen',
        style: TextStyle(color: Color(0xFFE1E2E8)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              EuroFormatter(),
            ],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFE1E2E8)),
            cursorColor: Color(0xffa0cafd),
            decoration: InputDecoration(
              suffixText: "€",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffa0cafd)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffC3C7CF)),
              ),
              hintText: 'Betrag',
              hintStyle: TextStyle(color: Color(0xffC3C7CF)),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zum bestehenden Betrag addieren',
                style: TextStyle(color: Color(0xFFE1E2E8)),
              ),
              Switch(
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(Icons.add, color: Color(0xffa0cafd));
                  }
                  return null;
                }),
                value: idAdd,
                onChanged: (value) {
                  setState(() {
                    idAdd = value;
                  });
                },
                activeColor: Color(0xff003258),
                activeTrackColor: Color(0xffa0cafd),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Abbrechen',
            style: TextStyle(color: Color(0xffa0cafd)),
          ),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(_controller.text);

            if (value != null && value >= 0) {
              final box = Hive.box<Betrag>('betraege');
              final lastAmount = box.values.isNotEmpty
                  ? box.values.last.geldMenge ?? 0.0
                  : 0.0;
              double newAmount = idAdd ? lastAmount + value : value;

              final amount = Betrag(newAmount);
              box.add(amount);

              widget.updateStateExtern();

              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bitte eine gültige Zahl eingeben.')),
              );
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Color(0xffa0cafd)),
            foregroundColor: WidgetStatePropertyAll<Color>(Color(0xff003258)),
          ),
          child: Text('Speichern'),
        ),
      ],
    );
  }
}

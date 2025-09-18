import 'package:expenditure/constants/category_constants.dart';
import 'package:expenditure/data/ausgabe.dart';
import 'package:expenditure/services/expense_calculation_service.dart';
import 'package:expenditure/widgets/bar_chart_widget.dart';
import 'package:expenditure/widgets/open_kategorie_filter_dialog.dart';
import 'package:expenditure/widgets/time_range_selector.dart';
import 'package:flutter/material.dart';

class ExpensesChartScreen extends StatefulWidget {
  final List<Ausgabe> ausgaben;

  const ExpensesChartScreen({super.key, required this.ausgaben});

  @override
  State<ExpensesChartScreen> createState() => _ExpensesChartScreenState();
}

class _ExpensesChartScreenState extends State<ExpensesChartScreen> {
  String _zeitraum = 'Heute';
  String text = 'Heute';
  List<String> ausgewaehlteKategorien = [];
  String filterKategorie = 'Alle';
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    final daten = berechneSummen(
      widget.ausgaben,
      _zeitraum,
      filterKategorie,
      ausgewaehlteKategorien,
    );
    final gesamtsumme = berechneGesamtausgaben(daten, _zeitraum);

    text =
        _zeitraum == 'Heute'
            ? 'Heute'
            : (_zeitraum == 'Woche' ? 'diese Woche' : 'diese Monat');

    return Scaffold(
      backgroundColor: const Color(0xff191C20),
      appBar: AppBar(
        title: const Text("Statistiken"),
        backgroundColor: const Color(0xFF272A2F),
        foregroundColor: const Color(0xFFE1E2E8),
        actions: [
          if (_zeitraum == 'Woche' || _zeitraum == 'Monat')
            IconButton(
              onPressed: _openKategorieFilterDialog,
              icon: Icon(
                isChecked ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: const Color(0xFFE1E2E8),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          _buildSummaryBox(gesamtsumme),
          const SizedBox(height: 30),
          TimeRangeSelector(
            zeitraum: _zeitraum,
            onChanged: (String neuerZeitraum) {
              setState(() => _zeitraum = neuerZeitraum);
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BarChartWidget(data: daten, period: _zeitraum),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(double gesamtsumme) {
    return Container(
      alignment: Alignment.center,
      width: 350,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xffA0CAFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Meine Ausgaben für $text",
            style: const TextStyle(fontSize: 20, color: Color(0xff003258)),
          ),
          const SizedBox(height: 10),
          Text(
            "${gesamtsumme.toStringAsFixed(2)} €",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xff003258),
            ),
          ),
        ],
      ),
    );
  }

  void _openKategorieFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return OpenKategorieFilterDialog(
          kategorien: kategorien,
          ausgewaehlteKategorien: ausgewaehlteKategorien,
          onFilterSelected: (neueKategorien) {
            setState(() {
              ausgewaehlteKategorien = neueKategorien.toList();
              filterKategorie =
                  neueKategorien.isEmpty ? 'Alle' : neueKategorien.join(', ');
            });
          },
        );
      },
    );
  }
}

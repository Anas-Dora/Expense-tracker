// ignore_for_file: file_names

import 'package:expenditure/constants/category_constants.dart';
import 'package:expenditure/data/ausgabe.dart';
import 'package:expenditure/repository/expenses_repository.dart';
import 'package:expenditure/utils/date_utils.dart';
import 'package:expenditure/utils/expense_utils.dart';
import 'package:expenditure/widgets/add_expenses_dialog.dart';
import 'package:expenditure/widgets/budget_display.dart';
import 'package:expenditure/widgets/delete_confirmation_dialog.dart';
import 'package:expenditure/widgets/expenses_display.dart';
import 'package:expenditure/widgets/start_amount_input_dialog.dart';
import 'package:flutter/material.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => ExpensesListScreenState();
}

class ExpensesListScreenState extends State<ExpensesListScreen> {
  late final ExpensesRepository repository;
  List<Ausgabe> ausgaben = [];
  String filterKategorie = 'Alle';
  double startingAmount = 00.0;

  List<Ausgabe> get getAusgaben => ausgaben;

  double get remainingAmount {
    final (startDatum, endDatum) = DateRangeHelper.calculateCurrentRange();
    final totalAusgaben = ausgaben
        .where(
          (a) =>
              a.datum.isAfter(startDatum.subtract(Duration(seconds: 1))) &&
              a.datum.isBefore(endDatum),
        )
        .fold(0.0, (sum, item) => sum + item.betrag);
    return startingAmount - totalAusgaben;
  }

  @override
  void initState() {
    super.initState();
    repository = ExpensesRepository();
    _ladeData();
  }

  void _ladeData() {
    setState(() {
      startingAmount = repository.getStartingAmount();
      ausgaben = repository.fetchAusgaben();
    });
  }

  void _ausgabeHinzufuegen() async {
    final neueAusgabe = await showDialog<Ausgabe>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AddExpensesDialog(kategorien: kategorien);
          },
        );
      },
    );

    if (neueAusgabe != null) {
      setState(() {
        ausgaben.add(neueAusgabe);
      });
    }
  }

  void _startBetragEingeben() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setState) =>
                  StartAmountInputDialog(updateStateExtern: () => _ladeData()),
        );
      },
    );
  }

  void clearData() {
    setState(() {
      ausgaben.clear();
      repository.clearAll();
      startingAmount = 0.0;
    });
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeleteConfirmationDialog(clearData: clearData),
    );
  }

  void deleteAusgabe(Ausgabe ausgabe) {
    setState(() {
      repository.deleteAusgabe(ausgabe);
      ausgaben.remove(ausgabe);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gefilterteAusgaben =
        filterKategorie == 'Alle'
            ? ausgaben
            : ausgaben.where((a) => a.kategorie == filterKategorie).toList();

    final gruppierteAusgaben = ExpenseGrouper.groupByDate(gefilterteAusgaben);

    final sortedDates =
        gruppierteAusgaben.keys.toList()..sort((a, b) => b.compareTo(a));

    final spentAmount = startingAmount - remainingAmount;

    return Scaffold(
      backgroundColor: Color(0xff191C20),
      appBar: AppBar(
        title: Text('Ausgaben Tracker'),
        backgroundColor: Color(0xFF272A2F),
        foregroundColor: Color(0xFFE1E2E8),
        actions: [
          DropdownButton<String>(
            icon: Icon(Icons.arrow_drop_down, color: Color(0xFFE1E2E8)),
            value: filterKategorie,
            onChanged: (value) => setState(() => filterKategorie = value!),
            items:
                kategorien
                    .map(
                      (k) => DropdownMenuItem(
                        value: k,
                        child: Text(
                          k,
                          style: TextStyle(color: Color(0xFFE1E2E8)),
                        ),
                      ),
                    )
                    .toList(),
            dropdownColor: Color(0xff272A2F),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: BudgetDisplay(
              remainingAmount: remainingAmount,
              startingAmount: startingAmount,
              spentAmount: spentAmount,
              startBetragEingeben: _startBetragEingeben,
              showDeleteConfirmationDialog: showDeleteConfirmationDialog,
            ),
          ),
          ExpenseDisplay(
            gruppierteAusgaben: gruppierteAusgaben,
            sortedDates: sortedDates,
            ausgaben: ausgaben,
            onDelete: deleteAusgabe,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff194975),
        onPressed: _ausgabeHinzufuegen,
        child: Icon(Icons.add, color: Color(0xffD1E4FF)),
      ),
    );
  }
}

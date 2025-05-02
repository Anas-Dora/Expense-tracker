// ignore_for_file: file_names

import 'package:expenditure/ausgabe.dart';
import 'package:expenditure/betrag.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class AusgabenListe extends StatefulWidget {
  const AusgabenListe({super.key});

  @override
  State<AusgabenListe> createState() => AusgabenListeState();
}

class AusgabenListeState extends State<AusgabenListe> {
  List<Ausgabe> ausgaben = [];
  String filterKategorie = 'Alle';
  static const List<String> kategorien = [
    'Alle',
    'Essen & Trinken',
    'Kleidung',
    'Ratenzahlungen',
    'Für Zimmer',
    'Sonstiges',
  ];

  List<Ausgabe> get getAusgaben => ausgaben;

  void clearAusgaben() {
    setState(() {
      ausgaben.clear(); // <-- Korrekt: direkte Liste leeren
    });
  }

  double startBetrag = 00.0;

  @override
  void initState() {
    super.initState();
    _ladeData();
  }

  double get verbleibenderBetrag {
    final now = DateTime.now();

    // Zeitraum vom 27. bis 27. berechnen
    DateTime startDatum;
    DateTime endDatum;

    if (now.day < 27) {
      // Zeitraum vom 27. des Vormonats bis 27. diesen Monats
      if (now.month == 1) {
        startDatum = DateTime(now.year - 1, 12, 27);
      } else {
        startDatum = DateTime(now.year, now.month - 1, 27);
      }
      endDatum = DateTime(now.year, now.month, 27);
    } else {
      // Zeitraum vom 27. diesen Monats bis 27. des nächsten Monats
      startDatum = DateTime(now.year, now.month, 27);
      if (now.month == 12) {
        endDatum = DateTime(now.year + 1, 1, 27);
      } else {
        endDatum = DateTime(now.year, now.month + 1, 27);
      }
    }

    // Nur Ausgaben in diesem Zeitraum berücksichtigen
    final totalAusgaben = ausgaben
        .where(
          (a) =>
              a.datum.isAfter(startDatum.subtract(Duration(seconds: 1))) &&
              a.datum.isBefore(endDatum),
        )
        .fold(0.0, (sum, item) => sum + item.betrag);
    return startBetrag - totalAusgaben;
  }

  void _ausgabeHinzufuegen() async {
    final betragController = TextEditingController();
    final beschreibungController = TextEditingController();
    String gewaehlteKategorie = kategorien[1];

    final neueAusgabe = await showDialog<Ausgabe>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xff272a2f),
              title: Text(
                'Neue Ausgabe',
                style: TextStyle(color: Color(0xffe1e2e8)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: betragController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: Color(0xffe1e2e8)),
                    cursorColor: Color(0xffa0cafd),
                    decoration: InputDecoration(
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
                  SizedBox(height: 10),
                  TextField(
                    controller: beschreibungController,
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
                  SizedBox(height: 10),
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
                      initialSelection: gewaehlteKategorie,

                      onSelected: (value) {
                        if (value != null) {
                          setState(() {
                            gewaehlteKategorie = value;
                          });
                        }
                      },
                      dropdownMenuEntries:
                          kategorien
                              .where((k) => k != 'Alle')
                              .map(
                                (k) => DropdownMenuEntry(
                                  value: k,
                                  label: k,
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
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
                  child: Text(
                    'Abbrechen',
                    style: TextStyle(color: Color(0xffa0cafd)),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final betrag = double.tryParse(betragController.text);
                    final beschreibung = beschreibungController.text;

                    if (betrag != null && beschreibung.isNotEmpty) {
                      final ausgabebox = Hive.box<Ausgabe>('ausgaben');
                      final neueAusgabe = Ausgabe(
                        betrag,
                        beschreibung,
                        gewaehlteKategorie,
                        DateTime.now(),
                      );
                      ausgabebox.add(neueAusgabe);

                      Navigator.pop(context, neueAusgabe);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Color(0xffa0cafd),
                    ),
                    foregroundColor: WidgetStatePropertyAll<Color>(
                      Color(0xff003258),
                    ),
                  ),
                  child: Text('Hinzufügen'),
                ),
              ],
            );
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

  void _ladeData() {
    final betraegeBox = Hive.box<Betrag>('betraege');
    if (betraegeBox.isNotEmpty) {
      final letzterBetrag = betraegeBox.values.last;
      setState(() {
        startBetrag = letzterBetrag.geldMenge ?? 0.0;
      });
      final ausgabenBox = Hive.box<Ausgabe>('ausgaben');
      ausgaben = ausgabenBox.values.toList();
    }
  }

  void _startBetragEingeben() {
    final controller = TextEditingController();
    final brightness = Theme.of(context).brightness;
    final backgroundColor =
        brightness == Brightness.light
            ? const Color(0xFF272A2F)
            : const Color(0xFFE6E8EE);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Betrag festlegen',
              style: TextStyle(color: Color(0xFFE1E2E8)),
            ),
            backgroundColor: backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  cursorColor: Color(0xffa0cafd),
                  style: TextStyle(color: Color(0xFFE1E2E8)),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffa0cafd)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xffC3C7CF)),
                    ),
                    focusColor: Color(0xffa0cafd),
                    hintText: 'Betrag',
                    hintStyle: TextStyle(color: Color(0xffC3C7CF)),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Abbrechen',
                  style: TextStyle(color: Color(0xffa0cafd)),
                ),
              ),
              FilledButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);

                  if (value != null && value >= 0) {
                    final betrag = Betrag(value);
                    final box = Hive.box<Betrag>('betraege');

                    box.add(betrag);

                    setState(() {
                      startBetrag = value;
                    });

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bitte eine gültige Zahl eingeben.'),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    Color(0xffa0cafd),
                  ),
                  foregroundColor: WidgetStatePropertyAll<Color>(
                    Color(0xff003258),
                  ),
                ),
                child: Text('Speichern'),
              ),
            ],
          ),
    );
  }

  Widget buildPopupMenu() {
    const Color textColor = Color(0xffe1e2e8);
    const Color backgroundColor = Color(0xff272a2f);
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(popupMenuTheme: PopupMenuThemeData(color: backgroundColor)),
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color: Color(0xffD1E4FF),
        ), // Icon des Buttons
        onSelected: (value) {
          if (value == 'add') {
            _startBetragEingeben();
          } else if (value == 'delete') {
            showDeleteConfirmationDialog(context);
          }
        },
        itemBuilder:
            (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'add',
                child: Row(
                  children: const [
                    Icon(Icons.add, color: textColor),
                    SizedBox(width: 8),
                    Text(
                      'Geld hinzufügen',
                      style: const TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: const [
                    Icon(Icons.delete, color: textColor),
                    SizedBox(width: 8),
                    Text(
                      'Alles löschen',
                      style: const TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
            ],
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xff272a2f),
            title: const Text(
              'Bestätigen',
              style: TextStyle(color: Color(0xffe1e2e8)),
            ),
            content: const Text(
              'Möchtest du wirklich alle Ausgaben löschen?',
              style: TextStyle(color: Color(0xffe1e2e8)),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(color: Color(0xffe1e2e8)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  'Löschen',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Alle daten Löschen
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gefilterteAusgaben =
        filterKategorie == 'Alle'
            ? ausgaben
            : ausgaben.where((a) => a.kategorie == filterKategorie).toList();

    final Map<DateTime, List<Ausgabe>> gruppierteAusgaben = {};

    for (var ausgabe in gefilterteAusgaben) {
      final datum = DateTime(
        ausgabe.datum.year,
        ausgabe.datum.month,
        ausgabe.datum.day,
      );
      if (!gruppierteAusgaben.containsKey(datum)) {
        gruppierteAusgaben[datum] = [];
      }
      gruppierteAusgaben[datum]!.add(ausgabe);
    }

    final sortedDates =
        gruppierteAusgaben.keys.toList()..sort((a, b) => b.compareTo(a));
    final ausgegebeneBetrag = startBetrag - verbleibenderBetrag;

    final brightness = Theme.of(context).brightness;
    final backgroundColor =
        brightness == Brightness.light
            ? const Color(0xFF272A2F)
            : const Color(0xFFE6E8EE);
    return Scaffold(
      backgroundColor: Color(0xff191C20),
      appBar: AppBar(
        title: Text('Ausgaben Tracker'),
        backgroundColor: backgroundColor,
        foregroundColor: Color(0xFFE1E2E8),
        actions: [
          DropdownButton<String>(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 355,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color(0xff194975),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Kontostand:",
                              style: TextStyle(
                                color: Color(0xffD1E4FF),
                                fontSize: 14,
                              ),
                            ),
                            buildPopupMenu(),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${verbleibenderBetrag.toStringAsFixed(2)} €',
                        style: TextStyle(
                          color: Color(0xffD1E4FF),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 150,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xff194975),
                              border: Border.all(color: Color(0xffD1E4FF)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        9,
                                        4,
                                        0,
                                        4,
                                      ),
                                      child: Text(
                                        "Budget:",
                                        style: TextStyle(
                                          color: Color(0xffD1E4FF),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    '${startBetrag.toStringAsFixed(2)} €',
                                    style: TextStyle(
                                      color: Color(0xffD1E4FF),
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xff194975),
                              border: Border.all(color: Color(0xffD1E4FF)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        9,
                                        4,
                                        0,
                                        4,
                                      ),
                                      child: Text(
                                        "Ausgaben:",
                                        style: TextStyle(
                                          color: Color(0xffD1E4FF),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    '${ausgegebeneBetrag.toStringAsFixed(2)} €',
                                    style: TextStyle(
                                      color: Color(0xffD1E4FF),
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: gruppierteAusgaben.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final ausgabenAnDemTag =
                    gruppierteAusgaben[date]!
                      ..sort((a, b) => b.datum.compareTo(a.datum));

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xffA0CAFD),
                    // Heller Hintergrund im Light Mode
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(date),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff003258),
                        ),
                      ),
                      Divider(color: Color(0xff2E3135)),
                      ...ausgabenAnDemTag.map((ausgabe) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onLongPress: () {
                            setState(() {
                              ausgabe.delete();
                              ausgaben.remove(ausgabe);
                            });
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ausgabe.beschreibung,
                                style: TextStyle(
                                  color: Color(0xff003258),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '- ${ausgabe.betrag.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  color: Color(0xffBA1A1A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${ausgabe.kategorie}',
                            style: TextStyle(
                              color: Color(0xff003258),
                              fontSize: 16,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
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

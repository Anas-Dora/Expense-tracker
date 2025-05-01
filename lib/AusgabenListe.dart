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
              title: Text('Neue Ausgabe'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: betragController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(labelText: 'Betrag'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: beschreibungController,
                    decoration: InputDecoration(labelText: 'Beschreibung'),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: gewaehlteKategorie,
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          gewaehlteKategorie = value;
                        });
                      }
                    },
                    items:
                        kategorien
                            .where((k) => k != 'Alle')
                            .map(
                              (k) => DropdownMenuItem(value: k, child: Text(k)),
                            )
                            .toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Abbrechen'),
                ),
                ElevatedButton(
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

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Betrag festlegen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Betrag',
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
                child: Text('Abbrechen'),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);

                  if (value != null && value >= 0) {
                    final betrag = Betrag(value);
                    final box = Hive.box<Betrag>('betraege');

                    box.add(betrag); // 💾 speichert den Betrag in Hive

                    setState(() {
                      startBetrag = value;
                    });

                    Navigator.pop(context);
                  } else {
                    // Optional: Zeige einen Fehlerdialog oder SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bitte eine gültige Zahl eingeben.'),
                      ),
                    );
                  }
                },
                child: Text('Speichern'),
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

    // Optional: sortieren, neueste Tage zuerst
    final sortedDates =
        gruppierteAusgaben.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text('Ausgaben Tracker'),
        actions: [
          DropdownButton<String>(
            value: filterKategorie,
            onChanged: (value) => setState(() => filterKategorie = value!),
            items:
                kategorien
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
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
                GestureDetector(
                  onLongPress: () {
                    _startBetragEingeben();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100, // heller Grünton
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // abgerundete Ecken
                    ),

                    child: Text(
                      '${verbleibenderBetrag.toStringAsFixed(2)} €',
                      style: TextStyle(
                        color:
                            Colors
                                .green
                                .shade800, // dunkleres Grün für den Text

                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 10),
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
                    // Dynamisch je nach Helligkeit des Themas
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors
                                .grey
                                .shade800 // Dunkler Hintergrund im Dark Mode
                            : Colors
                                .grey
                                .shade100, // Heller Hintergrund im Light Mode
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          // Dynamische Textfarbe je nach Modus
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors
                                      .white // Textfarbe im Dark Mode
                                  : Colors
                                      .blueAccent, // Textfarbe im Light Mode
                        ),
                      ),
                      Divider(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors
                                    .white70 // Helle Trennlinie im Dark Mode
                                : Colors
                                    .black45, // Dunklere Trennlinie im Light Mode
                      ),
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
                              Text(ausgabe.beschreibung),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Colors
                                          .red
                                          .shade100, // Rote Hintergrundfarbe für Betrag
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '- ${ausgabe.betrag.toStringAsFixed(2)} €',
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${ausgabe.kategorie}',
                            style: TextStyle(
                              fontSize: 16,
                              // Dynamische Subtextfarbe je nach Modus
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors
                                          .white // Subtextfarbe im Dark Mode
                                      : Colors
                                          .black, // Subtextfarbe im Light Mode
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
        backgroundColor: Colors.blue.shade800,
        onPressed: _ausgabeHinzufuegen,
        child: Icon(Icons.add, color: Colors.blue.shade100),
      ),
    );
  }
}

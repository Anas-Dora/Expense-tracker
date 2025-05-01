// ignore_for_file: file_names

import 'package:expenditure/AusgabenListe.dart';
import 'package:expenditure/ausgabe.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarGraph extends StatefulWidget {
  final List<Ausgabe> ausgaben;

  const BarGraph({super.key, required this.ausgaben});

  @override
  State<BarGraph> createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  String _zeitraum = 'Tag';
  List<String> ausgewaehlteKategorien = [];
  String filterKategorie = 'Alle';

  Map<String, Map<String, double>> _berechneSummen(List<Ausgabe> ausgaben) {
    DateTime heute = DateTime.now();
    Map<String, Map<String, double>> summen = {};

    List<Ausgabe> gefilterteAusgaben =
        ausgaben.where((a) {
          if (filterKategorie == 'Alle') {
            return true;
          } else {
            return ausgewaehlteKategorien.contains(a.kategorie);
          }
        }).toList();

    if (_zeitraum == 'Tag') {
      DateTime heuteStart = DateTime(heute.year, heute.month, heute.day);
      DateTime heuteEnde = heuteStart.add(Duration(days: 1));

      List<Ausgabe> heuteAusgaben =
          gefilterteAusgaben
              .where(
                (a) =>
                    a.datum.isAfter(heuteStart) && a.datum.isBefore(heuteEnde),
              )
              .toList();

      summen['Heute'] = {};
      for (var a in heuteAusgaben) {
        summen['Heute']![a.kategorie] =
            (summen['Heute']![a.kategorie] ?? 0) + a.betrag;
      }
    } else if (_zeitraum == 'Woche') {
      // Diese Kalenderwoche
      DateTime wochenstart = DateTime(
        heute.year,
        heute.month,
        heute.day - (heute.weekday - 1),
      );
      DateTime wochenende = wochenstart.add(
        Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      List<Ausgabe> wocheAusgaben =
          gefilterteAusgaben.where((a) {
            return a.datum.isAfter(
                  wochenstart.subtract(const Duration(seconds: 1)),
                ) &&
                a.datum.isBefore(wochenende.add(const Duration(seconds: 1)));
          }).toList();

      for (var a in wocheAusgaben) {
        String tag = DateFormat('dd.MM.').format(a.datum);
        if (!summen.containsKey(tag)) {
          summen[tag] = {};
        }
        summen[tag]![a.kategorie] = (summen[tag]![a.kategorie] ?? 0) + a.betrag;
      }
    } else if (_zeitraum == 'Monat') {
      // Ganze aktuelle Monat

      DateTime startDatum;
      DateTime endDatum;

      // Falls wir uns vor dem 27. im aktuellen Monat befinden, geht der Zeitraum vom 27. des Vormonats bis 27. des aktuellen Monats
      if (heute.day < 27) {
        if (heute.month == 1) {
          startDatum = DateTime(heute.year - 1, 12, 27);
        } else {
          startDatum = DateTime(heute.year, heute.month - 1, 27);
        }
        endDatum = DateTime(heute.year, heute.month, 27);
      } else {
        // Sonst: vom 27. dieses Monats bis zum 27. des nächsten Monats
        startDatum = DateTime(heute.year, heute.month, 27);
        if (heute.month == 12) {
          endDatum = DateTime(heute.year + 1, 1, 27);
        } else {
          endDatum = DateTime(heute.year, heute.month + 1, 27);
        }
      }

      List<Ausgabe> monatAusgaben =
          gefilterteAusgaben
              .where(
                (a) =>
                    a.datum.isAfter(
                      startDatum.subtract(const Duration(seconds: 1)),
                    ) &&
                    a.datum.isBefore(endDatum),
              )
              .toList();

      for (var a in monatAusgaben) {
        int woche = ((a.datum.day - 1) / 7).floor() + 1;
        String wocheLabel = 'Woche $woche';
        if (!summen.containsKey(wocheLabel)) {
          summen[wocheLabel] = {};
        }
        summen[wocheLabel]![a.kategorie] =
            (summen[wocheLabel]![a.kategorie] ?? 0) + a.betrag;
      }
    }

    return summen;
  }

  void _openKategorieFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // wichtig: setStateDialog!
            return AlertDialog(
              title: Text('Kategorien auswählen'),
              content: SingleChildScrollView(
                child: Column(
                  children:
                      AusgabenListeState.kategorien
                          .where((kategorie) => kategorie != 'Alle')
                          .map((kategorie) {
                            final isSelected = ausgewaehlteKategorien.contains(
                              kategorie,
                            );
                            return CheckboxListTile(
                              title: Text(kategorie),
                              value: isSelected,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  if (value == true) {
                                    ausgewaehlteKategorien.add(kategorie);
                                  } else {
                                    ausgewaehlteKategorien.remove(kategorie);
                                  }
                                });
                              },
                            );
                          })
                          .toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Fertig'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      filterKategorie =
                          ausgewaehlteKategorien.isEmpty
                              ? 'Alle'
                              : ausgewaehlteKategorien.join(', ');
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final daten = _berechneSummen(widget.ausgaben);

    return Scaffold(
      appBar: AppBar(
        title: Text("Statistiken"),
        actions: [
          if (_zeitraum == 'Woche' || _zeitraum == 'Monat')
            IconButton(
              onPressed: _openKategorieFilterDialog,
              icon: Icon(Icons.filter_alt),
            ),
        ],
      ),
      body:
          daten.isEmpty
              ? Center(
                child: Text("Keine Ausgaben verfügbar"),
              ) // Zeige eine Nachricht, wenn keine Ausgaben vorhanden sind
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: DropdownButton<String>(
                      value: _zeitraum,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _zeitraum = value;
                          });
                        }
                      },
                      items:
                          ['Tag', 'Woche', 'Monat']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "13314 €",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: buildBarChart(daten),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget buildBarChart(Map<String, Map<String, double>> daten) {
    final labels = daten.keys.toList();
    final kategorien =
        daten.values.expand((catMap) => catMap.keys).toSet().toList();

    final foreground = [
      Colors.purple.shade800,
      Colors.yellow.shade800,
      Colors.orange.shade800,
      Colors.cyan.shade800,
      Colors.brown.shade800,
      Colors.pink.shade800,
    ];
    final background = [Colors.grey.shade100];

    final Map<String, Color> foregroundKategorie = {
      for (int i = 0; i < kategorien.length; i++)
        kategorien[i]: foreground[i % foreground.length],
    };

    final Map<String, Color> backgroundkategorie = {
      for (int i = 0; i < kategorien.length; i++)
        kategorien[i]: background[i % background.length],
    };

    return BarChart(
      BarChartData(
        maxY: 500,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 45,
              showTitles: true,
              interval: 100,
              getTitlesWidget:
                  (value, meta) => Text(
                    '${value.toInt()} €',
                    style: TextStyle(fontSize: 15),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final labels = daten.keys.toList();

                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }

                return Text(
                  labels[index],
                  style: const TextStyle(fontSize: 15, color: Colors.red),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(labels.length, (index) {
          final catMap = daten[labels[index]]!;

          if (_zeitraum == 'Tag') {
            return BarChartGroupData(
              x: index,
              barRods:
                  kategorien.map((kategorie) {
                    final value = catMap[kategorie] ?? 0;
                    return BarChartRodData(
                      toY: value,
                      width: 20,
                      color: foregroundKategorie[kategorie] ?? Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    );
                  }).toList(),
              barsSpace: 8,
            );
          } else if (_zeitraum == 'Woche' || _zeitraum == 'Monat') {
            final gesamtsumme = catMap.values.fold(
              0.0,
              (sum, val) => sum + val,
            );
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: gesamtsumme.clamp(0, 500),
                  width: 40,
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              barsSpace: 8,
            );
          }

          return BarChartGroupData(x: 0, barRods: []);
        }),

        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) {
              if (_zeitraum == 'Tag') {
                String kategorie =
                    kategorien[group.x
                        .toInt()]; // Nutze die X-Position für die Kategorie
                return backgroundkategorie[kategorie] ?? Colors.grey.shade100;
              } else if (_zeitraum == 'Woche' || _zeitraum == 'Monat') {
                return Colors.blue.shade100;
              }
              return Colors.grey.shade200; // fallback
            },
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String kategorie;
              Color farbe;
              if (_zeitraum == 'Tag') {
                if (rodIndex < kategorien.length) {
                  kategorie = kategorien[rodIndex];
                  farbe = foregroundKategorie[kategorie] ?? Colors.grey;
                } else {
                  kategorie = 'Unbekannt';
                  farbe = Colors.grey;
                }
              } else {
                kategorie = 'Ausgaben';
                farbe = Colors.blue.shade800;
              }

              return BarTooltipItem(
                '$kategorie\n${rod.toY.toStringAsFixed(2)} €',
                TextStyle(
                  color: farbe,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

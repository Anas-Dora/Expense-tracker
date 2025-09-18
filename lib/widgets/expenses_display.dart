import 'package:expenditure/data/ausgabe.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseDisplay extends StatefulWidget {
  final Map<DateTime, List<Ausgabe>> gruppierteAusgaben;
  final List<DateTime> sortedDates;
  final List<Ausgabe> ausgaben;
  final Function(Ausgabe ausgabe) onDelete;

  const ExpenseDisplay({
    super.key,
    required this.gruppierteAusgaben,
    required this.sortedDates,
    required this.ausgaben,
    required this.onDelete,
  });

  @override
  State<ExpenseDisplay> createState() => _ExpenseDisplayState();
}

class _ExpenseDisplayState extends State<ExpenseDisplay> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final date = widget.sortedDates[index];
        final ausgabenAnDemTag = widget.gruppierteAusgaben[date]!
          ..sort((a, b) => b.datum.compareTo(a.datum));

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffA0CAFD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd.MM.yyyy').format(date),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff003258),
                ),
              ),
              Divider(color: Color(0xff2E3135)),
              // const SizedBox(height: 8),
              ...ausgabenAnDemTag.map((ausgabe) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onLongPress: () => widget.onDelete(ausgabe),
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
                    style: TextStyle(color: Color(0xff003258), fontSize: 16),
                  ),
                );
              }),
            ],
          ),
        );
      }, childCount: widget.sortedDates.length),
    );
  }
}

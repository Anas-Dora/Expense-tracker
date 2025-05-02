// ignore_for_file: file_names

import 'package:expenditure/AusgabenListe.dart';
import 'package:expenditure/Bargraph.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  final _ausgabenListeKey = GlobalKey<AusgabenListeState>();
  late BarGraph _barGraph;

  @override
  void initState() {
    super.initState();
    _barGraph = BarGraph(ausgaben: []);
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Wenn Statistiken geöffnet werden: Ausgaben aktualisieren
      final ausgaben = _ausgabenListeKey.currentState?.getAusgaben ?? [];
      setState(() {
        _barGraph = BarGraph(ausgaben: ausgaben);
      });
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      AusgabenListe(key: _ausgabenListeKey),
      _barGraph,
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Statistiken',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xff1D2024),
        selectedItemColor: Color(0xffD6E3F7),
        unselectedItemColor: Color(0xffC3C7CF),
        selectedIconTheme: IconThemeData(color: Color(0xffD6E3F7)),
        unselectedIconTheme: IconThemeData(color: Color(0xffC3C7CF)),
      ),
      body: screens[_selectedIndex],
    );
  }
}

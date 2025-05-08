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
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
            states,
          ) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                color: Color(0xffC3C7CF),
                fontWeight: FontWeight.bold,
              );
            }
            return const TextStyle(color: Color(0xffC3C7CF));
          }),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xff1D2024),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          indicatorColor: Color(0XFF3b4858),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xffC3C7CF)),
              selectedIcon: Icon(Icons.home, color: Color(0xffD6E3F7)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined, color: Color(0xffC3C7CF)),
              selectedIcon: Icon(Icons.analytics, color: Color(0xffD6E3F7)),
              label: 'Statistiken',
            ),
          ],
        ),
      ),

      body: screens[_selectedIndex],
    );
  }
}

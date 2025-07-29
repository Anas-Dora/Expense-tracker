// ignore_for_file: file_names

import 'package:expenditure/screens/expenses_list_screen.dart';
import 'package:expenditure/screens/expenses_chart_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _expensesListKey = GlobalKey<ExpensesListScreenState>();
  late ExpensesChartScreen _chartScreen;

  @override
  void initState() {
    super.initState();
    _initializeChartScreen();
  }

  void _initializeChartScreen() {
    _chartScreen = ExpensesChartScreen(ausgaben: []);
  }

  void _updateChartData() {
    final ausgaben = _expensesListKey.currentState?.getAusgaben ?? [];
    setState(() {
      _chartScreen = ExpensesChartScreen(ausgaben: ausgaben);
    });
  }

  void _onNavigationItemSelected(int index) {
    if (index == 1) _updateChartData();
    setState(() => _selectedIndex = index);
  }

  List<Widget> get _screens => [
    ExpensesListScreen(key: _expensesListKey),
    _chartScreen,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    return NavigationBarTheme(
      data: _navigationBarTheme(),
      child: NavigationBar(
        backgroundColor: const Color(0xff1D2024),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavigationItemSelected,
        indicatorColor: const Color(0XFF3b4858),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _navigationDestinations,
      ),
    );
  }

  NavigationBarThemeData _navigationBarTheme() {
    return NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
        (states) => TextStyle(
          color:
              states.contains(MaterialState.selected)
                  ? const Color(0xffC3C7CF)
                  : const Color(0xffC3C7CF),
          fontWeight:
              states.contains(MaterialState.selected)
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
    );
  }

  List<NavigationDestination> get _navigationDestinations => const [
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
  ];
}

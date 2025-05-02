// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:expenditure/ausgabe.dart';
import 'package:expenditure/betrag.dart';
import 'package:expenditure/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(BetragAdapter());
  await Hive.openBox<Betrag>('betraege');

  Hive.registerAdapter(AusgabeAdapter());
  await Hive.openBox<Ausgabe>('ausgaben');

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}

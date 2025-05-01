import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onDeleteAusgaben;
  final bool isDarkMode;
  final Function(ThemeMode) onThemeChanged;

  const AppDrawer({
    Key? key,
    required this.onDeleteAusgaben,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menü',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          // Toggle Theme with ToggleButtons
          TransactionToggle(
            children: [
              Icon(Icons.light_mode),
              Icon(Icons.phone_android), // Handy Icon
              Icon(Icons.dark_mode),
            ],
            onPressed: (index) {
              // Ändere das Thema je nach Auswahl
              if (index == 0) {
                onThemeChanged(ThemeMode.light); // Light Mode
              } else if (index == 1) {
                onThemeChanged(ThemeMode.system); // System Theme
              } else if (index == 2) {
                onThemeChanged(ThemeMode.dark); // Dark Mode
              }
            },
          ),
          // Delete Button
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Alle Ausgaben löschen'),
            onTap: () async {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Bestätigen'),
                      content: const Text(
                        'Möchtest du wirklich alle Ausgaben löschen?',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Abbrechen'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'Löschen',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            onDeleteAusgaben(); // Falls eine Funktion existiert, um darauf zu reagieren
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TransactionToggle extends StatefulWidget {
  final List<Widget> children;
  final Function(int) onPressed;

  TransactionToggle({required this.children, required this.onPressed});

  @override
  _TransactionToggleState createState() => _TransactionToggleState();
}

class _TransactionToggleState extends State<TransactionToggle> {
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = List.generate(widget.children.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ToggleButtons(
        children: widget.children,
        isSelected: _isSelected,
        onPressed: (int index) {
          setState(() {
            for (
              int buttonIndex = 0;
              buttonIndex < _isSelected.length;
              buttonIndex++
            ) {
              if (buttonIndex == index) {
                _isSelected[buttonIndex] = !_isSelected[buttonIndex];
              } else {
                _isSelected[buttonIndex] = false;
              }
            }
          });
          widget.onPressed(index); // Notify parent of the selected index
        },
        borderRadius: BorderRadius.circular(30),
        borderWidth: 2,
        constraints: BoxConstraints.expand(width: 90, height: 60),
      ),
    );
  }
}

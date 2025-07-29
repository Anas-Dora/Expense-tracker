import 'package:flutter/material.dart';

class TimeRangeSelector extends StatefulWidget {
  final String zeitraum;
  final Function(String) onChanged;
  const TimeRangeSelector({
    super.key,
    required this.zeitraum,
    required this.onChanged,
  });

  @override
  TimeRangeSelectorState createState() => TimeRangeSelectorState();
}

class TimeRangeSelectorState extends State<TimeRangeSelector> {
  int selectedIndex = 0;

  final List<String> _labels = ['Heute', 'Woche', 'Monat'];
  final List<IconData> _defaultIcons = [
    Icons.view_day,
    Icons.calendar_view_week,
    Icons.calendar_month,
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = _labels.indexOf(widget.zeitraum);
    if (selectedIndex == -1) selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderColor: Color(0xffc3c7cf),
      borderRadius: BorderRadius.circular(30),
      selectedBorderColor: Color(0xffd6e3f7),
      fillColor: Color(0xff3b4858),
      selectedColor: Color(0xffd6e3f7),
      color: Colors.grey,
      constraints: BoxConstraints(minHeight: 40.0, minWidth: 90.0),
      isSelected: List.generate(
        _labels.length,
        (index) => index == selectedIndex,
      ),
      onPressed: (int index) {
        setState(() {
          selectedIndex = index;
        });
        widget.onChanged(_labels[index]);
      },
      children: List.generate(_labels.length, (index) {
        IconData icon =
            index == selectedIndex ? Icons.check : _defaultIcons[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            SizedBox(width: 6),
            Text(_labels[index], style: TextStyle(color: Color(0xffc3c7cf))),
          ],
        );
      }),
    );
  }
}

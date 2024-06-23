import 'package:flutter/material.dart';

class CurrentStatus extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const CurrentStatus({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Current Status',
        border: OutlineInputBorder(),
      ),
    );
  }
}

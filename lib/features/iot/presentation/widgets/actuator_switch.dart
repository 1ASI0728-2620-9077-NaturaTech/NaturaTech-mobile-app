import 'package:flutter/material.dart';

class ActuatorSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const ActuatorSwitch({required this.label, required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Switch(
        value: value,
        activeThumbColor: const Color(0xFF00838F), // Corregido: antes era activeColor
        onChanged: onChanged,
      ),
    );
  }
}
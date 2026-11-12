import 'package:flutter/material.dart';

/// Valores de los umbrales de una planta.
class PlantThresholds {
  final double tempMin;
  final double tempMax;
  final double humMin;
  final double humMax;
  final double lightMin;

  const PlantThresholds({
    required this.tempMin,
    required this.tempMax,
    required this.humMin,
    required this.humMax,
    required this.lightMin,
  });

  static const PlantThresholds defaults = PlantThresholds(
    tempMin: 15,
    tempMax: 28,
    humMin: 40,
    humMax: 70,
    lightMin: 30,
  );
}

/// Editor visual de umbrales (Opción A): barras de rango para temperatura y
/// humedad (min-max en una sola barra) y una barra simple para la luz mínima.
class ThresholdsEditor extends StatefulWidget {
  final PlantThresholds initial;
  final ValueChanged<PlantThresholds> onChanged;

  const ThresholdsEditor({
    required this.initial,
    required this.onChanged,
    super.key,
  });

  @override
  State<ThresholdsEditor> createState() => _ThresholdsEditorState();
}

class _ThresholdsEditorState extends State<ThresholdsEditor> {
  late RangeValues _temp;
  late RangeValues _hum;
  late double _light;

  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    _temp = RangeValues(widget.initial.tempMin, widget.initial.tempMax);
    _hum = RangeValues(widget.initial.humMin, widget.initial.humMax);
    _light = widget.initial.lightMin;
  }

  void _emit() {
    widget.onChanged(PlantThresholds(
      tempMin: _temp.start,
      tempMax: _temp.end,
      humMin: _hum.start,
      humMax: _hum.end,
      lightMin: _light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.tune, color: _green, size: 20),
            SizedBox(width: 6),
            Text("Umbrales de los sensores (IoT)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Cuando un valor sale de estos límites, el dispositivo reacciona "
          "(riega, enciende la luz UV o suena la alarma).",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        _rangeCard(
          icon: Icons.thermostat,
          color: Colors.red,
          title: "Temperatura",
          suffix: "°C",
          values: _temp,
          min: -40,
          max: 80,
          onChanged: (v) {
            setState(() => _temp = v);
            _emit();
          },
        ),
        _rangeCard(
          icon: Icons.water_drop,
          color: Colors.blue,
          title: "Humedad",
          suffix: "%",
          values: _hum,
          min: 0,
          max: 100,
          onChanged: (v) {
            setState(() => _hum = v);
            _emit();
          },
        ),
        _singleCard(
          icon: Icons.wb_sunny,
          color: Colors.orange,
          title: "Luz mínima",
          suffix: "%",
          value: _light,
          min: 0,
          max: 100,
          onChanged: (v) {
            setState(() => _light = v);
            _emit();
          },
        ),
      ],
    );
  }

  Widget _rangeCard({
    required IconData icon,
    required Color color,
    required String title,
    required String suffix,
    required RangeValues values,
    required double min,
    required double max,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                "${values.start.round()}$suffix – ${values.end.round()}$suffix",
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ]),
            RangeSlider(
              values: values,
              min: min,
              max: max,
              divisions: (max - min).round(),
              activeColor: _green,
              labels: RangeLabels(
                "${values.start.round()}$suffix",
                "${values.end.round()}$suffix",
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _singleCard({
    required IconData icon,
    required Color color,
    required String title,
    required String suffix,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text("${value.round()}$suffix",
                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ]),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              activeColor: _green,
              label: "${value.round()}$suffix",
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

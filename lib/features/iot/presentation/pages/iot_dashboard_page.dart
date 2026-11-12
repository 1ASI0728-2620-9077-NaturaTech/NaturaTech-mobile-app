import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../domain/models/sensor_reading.dart';
import '../../domain/models/actuator_state.dart';
import '../../domain/repositories/iot_repository.dart';
import '../../../../core/ui/toast_helper.dart';

/// Vista IoT en vivo: sensores que se refrescan solos + control de actuadores.
class IotDashboardPage extends StatefulWidget {
  final int plantId;
  final String nodeCode;
  final String plantName;

  const IotDashboardPage({
    required this.plantId,
    required this.nodeCode,
    this.plantName = '',
    super.key,
  });

  @override
  State<IotDashboardPage> createState() => _IotDashboardPageState();
}

class _IotDashboardPageState extends State<IotDashboardPage> {
  final IotRepository _repo = GetIt.instance<IotRepository>();

  // Lo más rápido posible del lado de la app (el Wokwi/backend son el límite real).
  static const _refresh = Duration(milliseconds: 1500);
  // Tras tocar un botón, no refrescamos el estado un ratito para que no "parpadee".
  static const _actionGuard = Duration(seconds: 2);

  Timer? _timer;
  SensorReading? _reading;
  bool _hasData = false;
  bool _actuatorsBusy = false;
  ActuatorState _actuators = const ActuatorState();
  DateTime _lastAction = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _loadActuators();
    _tick();
    _timer = Timer.periodic(_refresh, (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _tick() async {
    await _fetchReading();
    // Refrescar el estado de los actuadores (para que el buzzer se re-arme en la
    // UI cuando el backend lo vuelve a activar), salvo justo después de una acción.
    if (DateTime.now().difference(_lastAction) > _actionGuard && !_actuatorsBusy) {
      await _loadActuators();
    }
  }

  Future<void> _fetchReading() async {
    try {
      final reading = await _repo.getLatestReading(widget.plantId);
      if (!mounted) return;
      setState(() {
        _reading = reading;
        _hasData = true;
      });
    } catch (_) {
      if (!mounted) return;
      if (_reading == null) setState(() => _hasData = false);
    }
  }

  Future<void> _loadActuators() async {
    try {
      final state = await _repo.getActuatorState(widget.nodeCode);
      if (!mounted) return;
      // No pisar si el usuario tocó algo mientras llegaba la respuesta.
      if (DateTime.now().difference(_lastAction) <= _actionGuard) return;
      setState(() => _actuators = state);
    } catch (_) {/* se conservan los modos actuales */}
  }

  Future<void> _changeActuator(ActuatorState newState, String label) async {
    final previous = _actuators;
    setState(() {
      _actuators = newState;
      _actuatorsBusy = true;
      _lastAction = DateTime.now();
    });
    try {
      await _repo.setActuatorState(widget.nodeCode, newState);
      if (!mounted) return;
      ToastHelper.show(context, "$label actualizado.");
    } catch (e) {
      if (!mounted) return;
      setState(() => _actuators = previous); // revertir si falla
      ToastHelper.error(context, "No se pudo cambiar $label.");
    } finally {
      if (mounted) {
        setState(() {
          _actuatorsBusy = false;
          _lastAction = DateTime.now();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plantName.isEmpty ? "Panel IoT" : "IoT · ${widget.plantName}"),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text("Sensores en vivo",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                _liveDot(),
              ],
            ),
            const SizedBox(height: 12),
            if (!_hasData)
              Card(
                color: Colors.blue[50],
                child: const ListTile(
                  leading: Icon(Icons.hourglass_empty, color: Colors.blue),
                  title: Text("Esperando datos del dispositivo..."),
                  subtitle: Text(
                      "Enciende el ESP32 (Wokwi o físico) para ver la telemetría."),
                ),
              ),
            _sensorCard("Humedad", _fmt(_reading?.humidityPercent, "%"),
                Icons.water_drop, Colors.blue),
            _sensorCard("Temperatura", _fmt(_reading?.airTemperature, " °C"),
                Icons.thermostat, Colors.red),
            _sensorCard("Gas / Aire", _fmt(_reading?.gasPercent, "%"),
                Icons.air, Colors.teal),
            _sensorCard("Luz", _fmt(_reading?.lightPercent, "%"),
                Icons.wb_sunny, Colors.orange),
            if (_reading != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text("Última actualización: ${_time(_reading!.timestamp)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
            const SizedBox(height: 28),
            const Text("Control de actuadores",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _actuatorControl(
              label: "Riego (bomba/servo)",
              icon: Icons.opacity,
              current: _actuators.servoMode,
              modes: const ["AUTO", "ON", "OFF"],
              labelFor: _modeLabel,
              onSelect: (m) =>
                  _changeActuator(_actuators.copyWith(servoMode: m), "Riego"),
            ),
            _actuatorControl(
              label: "Lámpara UV",
              icon: Icons.light_mode,
              current: _actuators.ledMode,
              modes: const ["AUTO", "ON", "OFF"],
              labelFor: _modeLabel,
              onSelect: (m) =>
                  _changeActuator(_actuators.copyWith(ledMode: m), "Lámpara UV"),
            ),
            _actuatorControl(
              label: "Alarma (buzzer)",
              icon: Icons.notifications_active,
              current: _actuators.buzzerMode,
              modes: const ["ON", "OFF"],
              labelFor: _buzzerLabel,
              onSelect: (m) =>
                  _changeActuator(_actuators.copyWith(buzzerMode: m), "Alarma"),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 4),
              child: Text(
                "La alarma se re-arma sola cuando un valor sale del umbral; "
                "usa \"Silenciar\" para apagarla.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Widgets --------------------
  Widget _liveDot() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _hasData ? Colors.green[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.circle, size: 8, color: _hasData ? Colors.green : Colors.grey),
        const SizedBox(width: 4),
        Text(_hasData ? "EN VIVO" : "SIN DATOS",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _hasData ? Colors.green[800] : Colors.grey[700])),
      ]),
    );
  }

  Widget _sensorCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(label),
        trailing: Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _actuatorControl({
    required String label,
    required IconData icon,
    required String current,
    required List<String> modes,
    required String Function(String) labelFor,
    required ValueChanged<String> onSelect,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 10),
            Row(
              children: modes.map((m) {
                final selected = current.toUpperCase() == m;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: SizedBox(
                        width: double.infinity,
                        child: Text(labelFor(m), textAlign: TextAlign.center),
                      ),
                      selected: selected,
                      onSelected: (_actuatorsBusy || selected)
                          ? null
                          : (_) => onSelect(m),
                      selectedColor: const Color(0xFF2E7D32),
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Helpers --------------------
  String _fmt(double? value, String suffix) {
    if (value == null) return "-- $suffix".trim();
    final text =
        suffix.contains("C") ? value.toStringAsFixed(1) : value.round().toString();
    return "$text$suffix";
  }

  String _modeLabel(String m) {
    switch (m) {
      case "AUTO":
        return "Auto";
      case "ON":
        return "Encender";
      case "OFF":
        return "Apagar";
      default:
        return m;
    }
  }

  String _buzzerLabel(String m) {
    switch (m) {
      case "ON":
        return "Armar";
      case "OFF":
        return "Silenciar";
      default:
        return m;
    }
  }

  String _time(DateTime t) {
    final l = t.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(l.hour)}:${two(l.minute)}:${two(l.second)}";
  }
}

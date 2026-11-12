import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/plant.dart';
import '../blocs/plant_bloc.dart';
import '../blocs/plant_event.dart';
import '../blocs/plant_state.dart';
import '../../../iot/presentation/pages/plant_iot_page.dart';
import '../../../tasks/presentation/pages/calendar_tasks_page.dart';
import 'edit_plant_page.dart';

class PlantDetailPage extends StatelessWidget {
  final Plant plant;

  const PlantDetailPage({required this.plant, super.key});

  /// Toma la versión más fresca de la planta desde el BLoC (así, tras "editar
  /// planta", esta vista se actualiza sola con los nuevos valores/umbrales).
  Plant _resolvePlant(PlantState state) {
    if (state is PlantLoaded) {
      for (final p in state.plants) {
        if (p.id == plant.id) return p;
      }
    }
    return plant;
  }

  Widget _buildInfoRow(IconData icon, Color iconColor, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdsCard(Plant plant) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 4),
              child: Row(children: [
                Icon(Icons.tune, size: 18, color: Color(0xFF2E7D32)),
                SizedBox(width: 8),
                Text("Umbrales de sensores (IoT)",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
            ),
            const Divider(height: 1),
            _buildInfoRow(Icons.thermostat, Colors.red, "Temperatura (mín – máx)",
                "${plant.temperatureThresholdMin.round()}°C – ${plant.temperatureThresholdMax.round()}°C"),
            const Divider(height: 1),
            _buildInfoRow(Icons.water_drop, Colors.blue, "Humedad (mín – máx)",
                "${plant.humidityThresholdMin.round()}% – ${plant.humidityThresholdMax.round()}%"),
            const Divider(height: 1),
            _buildInfoRow(Icons.wb_sunny, Colors.orange, "Luz mínima",
                "${plant.lightThresholdMin.round()}%"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlantBloc, PlantState>(
      builder: (context, state) {
        final plant = _resolvePlant(state);
        return Scaffold(
          appBar: AppBar(
            title: Text(plant.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  // Al guardar, el BLoC re-consulta las plantas y esta vista se
                  // actualiza sola (no hace falta cerrarla).
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditPlantPage(plant: plant)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => _confirmDelete(context, plant),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plant.imageUrl.isNotEmpty)
                  Image.network(
                    plant.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plant.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(plant.species,
                          style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      if (plant.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(plant.description, style: const TextStyle(fontSize: 14)),
                      ],
                      const SizedBox(height: 20),
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                plant.notificationsEnabled
                                    ? Icons.notifications_active
                                    : Icons.notifications_off,
                                plant.notificationsEnabled
                                    ? Colors.green
                                    : Colors.red,
                                'Notificaciones',
                                plant.notificationsEnabled
                                    ? 'Activadas'
                                    : 'Desactivadas',
                              ),
                              const Divider(height: 1),
                              if (plant.acquisitionDate.isNotEmpty)
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  Colors.orange,
                                  'Fecha de adquisicion',
                                  plant.acquisitionDate,
                                ),
                              if (plant.acquisitionDate.isNotEmpty &&
                                  plant.humidity.isNotEmpty)
                                const Divider(height: 1),
                              if (plant.humidity.isNotEmpty)
                                _buildInfoRow(
                                  Icons.water_drop,
                                  Colors.blue,
                                  'Nivel de humedad',
                                  plant.humidity,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildThresholdsCard(plant),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CalendarTasksPage(
                                      plantId: plant.id,
                                      profileId: plant.profileId,
                                      viewOnly: true,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.history,
                                  size: 18, color: Colors.white),
                              label: const Text("Historial de Tareas",
                                  style:
                                      TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlantIotPage(
                                      plantId: plant.id,
                                      profileId: plant.profileId,
                                      plantName: plant.name,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.sensors,
                                  size: 18, color: Colors.white),
                              label: const Text("IoT",
                                  style:
                                      TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Planta"),
        content: Text("Estas seguro de eliminar '${plant.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context
                  .read<PlantBloc>()
                  .add(DeletePlantEvent(plant.id, plant.profileId));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

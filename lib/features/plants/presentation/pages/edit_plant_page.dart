import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/plant.dart';
import '../blocs/plant_bloc.dart';
import '../blocs/plant_event.dart';
import '../blocs/plant_state.dart';
import '../widgets/thresholds_editor.dart';

class EditPlantPage extends StatefulWidget {
  final Plant plant;
  const EditPlantPage({required this.plant, super.key});

  @override
  State<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends State<EditPlantPage> {
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late String _selectedHumidity;
  late DateTime _acquisitionDate;
  late PlantThresholds _thresholds;
  bool _isSaving = false;

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  int _wateringIntervalDays() {
    switch (_selectedHumidity) {
      case 'ALTA':
        return 2;
      case 'MEDIA':
        return 4;
      case 'BAJA':
        return 7;
      default:
        return 4;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _speciesController = TextEditingController(text: widget.plant.species);
    _descriptionController =
        TextEditingController(text: widget.plant.description);
    _imageUrlController = TextEditingController(text: widget.plant.imageUrl);
    _selectedHumidity = widget.plant.humidity.isNotEmpty
        ? widget.plant.humidity.toUpperCase()
        : 'MEDIA';
    _acquisitionDate = DateTime.tryParse(widget.plant.acquisitionDate) ??
        DateTime.now();
    _thresholds = PlantThresholds(
      tempMin: widget.plant.temperatureThresholdMin,
      tempMax: widget.plant.temperatureThresholdMax,
      humMin: widget.plant.humidityThresholdMin,
      humMax: widget.plant.humidityThresholdMax,
      lightMin: widget.plant.lightThresholdMin,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _acquisitionDate = picked);
    }
  }

  void _savePlant() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre de la planta')),
      );
      return;
    }

    if (_speciesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa la especie')),
      );
      return;
    }

    final nextWatering =
        _acquisitionDate.add(Duration(days: _wateringIntervalDays()));

    final updatedPlant = Plant(
      id: widget.plant.id,
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      description: _descriptionController.text.trim(),
      acquisitionDate: _formatDate(_acquisitionDate),
      humidity: _selectedHumidity,
      nextWateringDate: _formatDate(nextWatering),
      imageUrl: _imageUrlController.text.trim(),
      notificationsEnabled: true,
      profileId: widget.plant.profileId,
      temperatureThresholdMin: _thresholds.tempMin,
      temperatureThresholdMax: _thresholds.tempMax,
      humidityThresholdMin: _thresholds.humMin,
      humidityThresholdMax: _thresholds.humMax,
      lightThresholdMin: _thresholds.lightMin,
    );

    _isSaving = true;
    context.read<PlantBloc>().add(UpdatePlantEvent(updatedPlant));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Planta")),
      body: BlocListener<PlantBloc, PlantState>(
        listener: (context, state) {
          if (state is PlantLoaded && _isSaving) {
            _isSaving = false;
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Planta actualizada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is PlantError && _isSaving) {
            _isSaving = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Nombre",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Ej. Mi Monstera",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.eco),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Especie",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _speciesController,
                  decoration: InputDecoration(
                    labelText: "Ej. Monstera Deliciosa",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.nature),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Descripcion",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Descripcion de la planta",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Fecha de adquisicion",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(_formatDate(_acquisitionDate)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Nivel de humedad requerido",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedHumidity,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.water_drop),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'BAJA',
                        child: Text('Baja - Riego cada 7 dias')),
                    DropdownMenuItem(
                        value: 'MEDIA',
                        child: Text('Media - Riego cada 4 dias')),
                    DropdownMenuItem(
                        value: 'ALTA',
                        child: Text('Alta - Riego cada 2 dias')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedHumidity = val);
                  },
                ),
                const SizedBox(height: 24),
                const Text("Foto de tu planta (URL)",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: "https://ejemplo.com/imagen.jpg",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 28),
                ThresholdsEditor(
                  initial: _thresholds,
                  onChanged: (t) => _thresholds = t,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _savePlant,
                    child: const Text("Guardar Cambios",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

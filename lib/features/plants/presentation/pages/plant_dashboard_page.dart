import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/plant.dart';
import '../blocs/plant_bloc.dart';
import '../blocs/plant_event.dart';
import '../blocs/plant_state.dart';
import '../widgets/plant_card.dart';
import '../pages/add_plant_page.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';

class PlantDashboardPage extends StatefulWidget {
  const PlantDashboardPage({super.key});

  @override
  State<PlantDashboardPage> createState() => _PlantDashboardPageState();
}

class _PlantDashboardPageState extends State<PlantDashboardPage> {
  int? _profileId;
  String? _weatherTemp;
  String? _weatherHumidity;
  String? _weatherDescription;
  bool _weatherLoaded = false;
  bool _weatherError = false;

  @override
  void initState() {
    super.initState();
    _loadPlants();
    _loadWeather();
  }

  Future<void> _loadPlants() async {
    final sessionManager = sl<SessionManager>();
    final userId = await sessionManager.getUserId();
    if (userId != null) {
      try {
        final profileRepo = sl<ProfileRepository>();
        final profile = await profileRepo.getProfileByUserId(userId);
        _profileId = profile.id;
      } catch (e) {
        _profileId = userId;
      }
      if (mounted && _profileId != null) {
        context.read<PlantBloc>().add(LoadPlants(_profileId!));
      }
    }
  }

  Future<void> _loadWeather() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get(
        ApiConstants.weather,
        queryParameters: {'city': 'Lima'},
      );

      if (!mounted) return;

      final rawData = response.data;

      Map<String, dynamic> data;
      if (rawData is String) {
        data = jsonDecode(rawData) as Map<String, dynamic>;
      } else if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else {
        setState(() {
          _weatherLoaded = true;
          _weatherError = true;
        });
        return;
      }

      String? temp;
      String? humidity;
      String? description;

      final main = data['main'];
      if (main is Map<String, dynamic>) {
        if (main['temp'] != null) {
          temp = '${(main['temp'] as num).toStringAsFixed(1)}°C';
        }
        if (main['humidity'] != null) {
          humidity = '${main['humidity']}%';
        }
      }

      final weatherList = data['weather'];
      if (weatherList is List && weatherList.isNotEmpty) {
        final w = weatherList[0];
        if (w is Map<String, dynamic> && w['description'] != null) {
          final desc = w['description'].toString();
          if (desc.isNotEmpty) {
            description = desc[0].toUpperCase() + desc.substring(1);
          }
        }
      }

      setState(() {
        _weatherTemp = temp;
        _weatherHumidity = humidity;
        _weatherDescription = description;
        _weatherLoaded = true;
        _weatherError = false;
      });
    } catch (e) {
      debugPrint("Weather error: $e");
      if (mounted) {
        setState(() {
          _weatherLoaded = true;
          _weatherError = true;
        });
      }
    }
  }

  Widget _buildWeatherWidget() {
    if (!_weatherLoaded) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Cargando clima...',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_weatherError) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.white70, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Lima - Clima no disponible',
                  style: TextStyle(color: Colors.white70)),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  _weatherLoaded = false;
                  _weatherError = false;
                });
                _loadWeather();
              },
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lima, Peru',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_weatherDescription != null)
                  Text(
                    _weatherDescription!,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.thermostat, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _weatherTemp ?? '--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.water_drop,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _weatherHumidity ?? '--',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Plantas')),
      body: Column(
        children: [
          _buildWeatherWidget(),
          Expanded(
            child: BlocBuilder<PlantBloc, PlantState>(
              builder: (context, state) {
                if (state is PlantLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PlantError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPlants,
                          child: const Text("Reintentar"),
                        ),
                      ],
                    ),
                  );
                }
                if (state is PlantLoaded) {
                  if (state.plants.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No tienes plantas registradas",
                              style: TextStyle(fontSize: 16)),
                          Text("Toca + para agregar una",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadPlants();
                      _loadWeather();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: state.plants.length,
                      itemBuilder: (context, index) =>
                          PlantCard(plant: state.plants[index]),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'chatbot',
            backgroundColor: const Color(0xFF1B5E20),
            onPressed: () {
              final state = context.read<PlantBloc>().state;
              final plants = state is PlantLoaded ? state.plants : <Plant>[];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatbotPage(plants: plants),
                ),
              );
            },
            child: const Icon(Icons.smart_toy, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'addPlant',
            backgroundColor: const Color(0xFF2E7D32),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddPlantPage(profileId: _profileId ?? 1),
                ),
              );
              if (result == true) {
                _loadPlants();
              }
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

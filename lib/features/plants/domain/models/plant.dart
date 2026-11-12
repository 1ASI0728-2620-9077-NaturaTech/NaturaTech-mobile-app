import 'package:equatable/equatable.dart';

class Plant extends Equatable {
  final int id;
  final String name;
  final String species;
  final String description;
  final String acquisitionDate;
  final String humidity;
  final String nextWateringDate;
  final String imageUrl;
  final bool notificationsEnabled;
  final int profileId;

  // Umbrales de los sensores (IoT). Con valores por defecto por si la planta
  // fue creada antes de que existieran.
  final double temperatureThresholdMin;
  final double temperatureThresholdMax;
  final double humidityThresholdMin;
  final double humidityThresholdMax;
  final double lightThresholdMin;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    this.description = '',
    this.acquisitionDate = '',
    this.humidity = '',
    this.nextWateringDate = '',
    required this.imageUrl,
    required this.notificationsEnabled,
    required this.profileId,
    this.temperatureThresholdMin = 15,
    this.temperatureThresholdMax = 28,
    this.humidityThresholdMin = 40,
    this.humidityThresholdMax = 70,
    this.lightThresholdMin = 30,
  });

  @override
  List<Object?> get props => [id, name, species, imageUrl, notificationsEnabled, profileId];
}

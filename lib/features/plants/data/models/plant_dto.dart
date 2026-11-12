import '../../domain/models/plant.dart';

class PlantDto {
  static double _d(dynamic v, double fallback) =>
      (v as num?)?.toDouble() ?? fallback;

  static Plant fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      species: json['species']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      acquisitionDate: json['acquisitionDate']?.toString() ?? '',
      humidity: json['humidity']?.toString() ?? '',
      nextWateringDate: json['nextWateringDate']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      profileId: json['profileId'] is int
          ? json['profileId']
          : (json['profileId'] as num?)?.toInt() ?? 0,
      temperatureThresholdMin: _d(json['temperatureThresholdMin'], 15),
      temperatureThresholdMax: _d(json['temperatureThresholdMax'], 28),
      humidityThresholdMin: _d(json['humidityThresholdMin'], 40),
      humidityThresholdMax: _d(json['humidityThresholdMax'], 70),
      lightThresholdMin: _d(json['lightThresholdMin'], 30),
    );
  }

  static Map<String, dynamic> _base(Plant plant) => {
        'name': plant.name,
        'species': plant.species,
        'description': plant.description,
        'acquisitionDate': plant.acquisitionDate,
        'humidity': plant.humidity,
        'nextWateringDate': plant.nextWateringDate,
        'imageUrl': plant.imageUrl,
        'notificationsEnabled': plant.notificationsEnabled,
        'profileId': plant.profileId,
        'temperatureThresholdMin': plant.temperatureThresholdMin,
        'temperatureThresholdMax': plant.temperatureThresholdMax,
        'humidityThresholdMin': plant.humidityThresholdMin,
        'humidityThresholdMax': plant.humidityThresholdMax,
        'lightThresholdMin': plant.lightThresholdMin,
      };

  static Map<String, dynamic> toCreateJson(Plant plant) => _base(plant);

  static Map<String, dynamic> toUpdateJson(Plant plant) => _base(plant);
}

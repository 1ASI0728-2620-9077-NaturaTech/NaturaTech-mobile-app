import '../../domain/models/sensor_reading.dart';

class SensorReadingDto {
  static SensorReading fromJson(Map<String, dynamic> json) {
    return SensorReading(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nodeId: (json['nodeId'] as num?)?.toInt() ?? 0,
      humidityPercent: (json['humidityPercent'] as num?)?.toDouble(),
      airTemperature: (json['airTemperature'] as num?)?.toDouble(),
      gasPercent: (json['gasPercent'] as num?)?.toDouble(),
      lightPercent: (json['lightPercent'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

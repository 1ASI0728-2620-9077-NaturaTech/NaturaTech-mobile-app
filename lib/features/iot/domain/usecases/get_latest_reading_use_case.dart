import '../models/sensor_reading.dart';
import '../repositories/iot_repository.dart';

class GetLatestReadingUseCase {
  final IotRepository repository;

  GetLatestReadingUseCase(this.repository);

  Future<SensorReading> execute(int nodeId) {
    return repository.getLatestReading(nodeId);
  }
}
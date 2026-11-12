import '../repositories/plant_repository.dart';

class DeletePlantUseCase {
  final PlantRepository repository;
  DeletePlantUseCase(this.repository);

  Future<void> execute(int plantId) {
    return repository.deletePlant(plantId);
  }
}

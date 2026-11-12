import '../models/plant.dart';
import '../repositories/plant_repository.dart';

class UpdatePlantUseCase {
  final PlantRepository repository;
  UpdatePlantUseCase(this.repository);

  Future<Plant> execute(Plant plant) {
    return repository.updatePlant(plant);
  }
}

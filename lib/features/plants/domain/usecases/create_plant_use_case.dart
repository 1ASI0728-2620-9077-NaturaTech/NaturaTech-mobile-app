import '../models/plant.dart';
import '../repositories/plant_repository.dart';

class CreatePlantUseCase {
  final PlantRepository repository;
  CreatePlantUseCase(this.repository);

  Future<Plant> execute(Plant plant) {
    return repository.createPlant(plant);
  }
}

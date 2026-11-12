import '../models/plant.dart';
import '../repositories/plant_repository.dart';

class GetPlantsUseCase {
  final PlantRepository repository;
  GetPlantsUseCase(this.repository);

  Future<List<Plant>> execute(int profileId) {
    return repository.getPlantsByProfile(profileId);
  }
}
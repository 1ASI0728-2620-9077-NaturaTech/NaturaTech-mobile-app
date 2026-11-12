import '../models/plant.dart';

abstract class PlantRepository {
  Future<List<Plant>> getPlantsByProfile(int profileId);
  Future<Plant> getPlantById(int plantId);
  Future<Plant> createPlant(Plant plant);
  Future<Plant> updatePlant(Plant plant);
  Future<void> deletePlant(int plantId);
}

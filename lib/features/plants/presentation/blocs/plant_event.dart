import 'package:equatable/equatable.dart';
import '../../domain/models/plant.dart';

abstract class PlantEvent extends Equatable {
  const PlantEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlants extends PlantEvent {
  final int profileId;
  const LoadPlants(this.profileId);

  @override
  List<Object?> get props => [profileId];
}

class CreatePlantEvent extends PlantEvent {
  final Plant plant;
  const CreatePlantEvent(this.plant);

  @override
  List<Object?> get props => [plant];
}

class UpdatePlantEvent extends PlantEvent {
  final Plant plant;
  const UpdatePlantEvent(this.plant);

  @override
  List<Object?> get props => [plant];
}

class DeletePlantEvent extends PlantEvent {
  final int plantId;
  final int profileId;
  const DeletePlantEvent(this.plantId, this.profileId);

  @override
  List<Object?> get props => [plantId, profileId];
}

import 'package:equatable/equatable.dart';
import '../../domain/models/plant.dart';

abstract class PlantState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<Plant> plants;
  PlantLoaded(this.plants);

  @override
  List<Object?> get props => [plants];
}

class PlantError extends PlantState {
  final String message;
  PlantError(this.message);

  @override
  List<Object?> get props => [message];
}

class PlantActionSuccess extends PlantState {
  final String message;
  PlantActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

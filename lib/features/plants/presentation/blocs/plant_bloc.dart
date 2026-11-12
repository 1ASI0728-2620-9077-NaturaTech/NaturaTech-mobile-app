import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/plant.dart';
import '../../domain/usecases/get_plants_use_case.dart';
import '../../domain/usecases/create_plant_use_case.dart';
import '../../domain/usecases/delete_plant_use_case.dart';
import '../../domain/usecases/update_plant_use_case.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import 'plant_event.dart';
import 'plant_state.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final GetPlantsUseCase getPlants;
  final CreatePlantUseCase createPlant;
  final DeletePlantUseCase deletePlant;
  final UpdatePlantUseCase updatePlant;
  final TaskRepository taskRepository;

  PlantBloc({
    required this.getPlants,
    required this.createPlant,
    required this.deletePlant,
    required this.updatePlant,
    required this.taskRepository,
  }) : super(PlantInitial()) {
    on<LoadPlants>((event, emit) async {
      emit(PlantLoading());
      try {
        final plants = await getPlants.execute(event.profileId);
        emit(PlantLoaded(plants));
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });

    on<CreatePlantEvent>((event, emit) async {
      emit(PlantLoading());
      try {
        await createPlant.execute(event.plant);
        final plants = await getPlants.execute(event.plant.profileId);
        emit(PlantLoaded(plants));
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });

    on<UpdatePlantEvent>((event, emit) async {
      emit(PlantLoading());
      try {
        await updatePlant.execute(event.plant);
        final plants = await getPlants.execute(event.plant.profileId);
        emit(PlantLoaded(plants));
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });

    on<DeletePlantEvent>((event, emit) async {
      final currentPlants =
          state is PlantLoaded ? (state as PlantLoaded).plants : <Plant>[];
      try {
        final tasks = await taskRepository.getTasksByPlant(event.plantId);
        for (final task in tasks) {
          await taskRepository.deleteTask(task.id);
        }
        await deletePlant.execute(event.plantId);
        final updated =
            currentPlants.where((p) => p.id != event.plantId).toList();
        emit(PlantLoaded(updated));
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });
  }
}

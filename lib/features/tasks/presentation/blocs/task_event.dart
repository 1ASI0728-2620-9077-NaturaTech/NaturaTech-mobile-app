import 'package:equatable/equatable.dart';
import '../../domain/models/task.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final int plantId;
  LoadTasks(this.plantId);

  @override
  List<Object?> get props => [plantId];
}

class LoadPendingTasks extends TaskEvent {
  final int plantId;
  LoadPendingTasks(this.plantId);

  @override
  List<Object?> get props => [plantId];
}

class LoadAllPlantsTasks extends TaskEvent {
  final List<int> plantIds;
  LoadAllPlantsTasks(this.plantIds);

  @override
  List<Object?> get props => [plantIds];
}

class CreateTaskEvent extends TaskEvent {
  final Task task;
  final List<int>? allPlantIds;
  CreateTaskEvent(this.task, {this.allPlantIds});

  @override
  List<Object?> get props => [task, allPlantIds];
}

class CompleteTaskEvent extends TaskEvent {
  final int taskId;
  final int plantId;
  final List<int>? allPlantIds;
  CompleteTaskEvent(this.taskId, this.plantId, {this.allPlantIds});

  @override
  List<Object?> get props => [taskId, plantId, allPlantIds];
}

class DeleteTaskEvent extends TaskEvent {
  final int taskId;
  final int plantId;
  final List<int>? allPlantIds;
  DeleteTaskEvent(this.taskId, this.plantId, {this.allPlantIds});

  @override
  List<Object?> get props => [taskId, plantId, allPlantIds];
}

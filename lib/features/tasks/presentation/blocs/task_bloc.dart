import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_tasks_use_case.dart';
import '../../domain/usecases/create_task_use_case.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasks;
  final CreateTaskUseCase createTask;
  final TaskRepository repository;

  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.repository,
  }) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await getTasks.getAll(event.plantId);
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<LoadPendingTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await getTasks.execute(event.plantId);
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<LoadAllPlantsTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final List<Task> allTasks = [];
        for (final plantId in event.plantIds) {
          final tasks = await getTasks.execute(plantId);
          allTasks.addAll(tasks);
        }
        allTasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
        emit(TaskLoaded(allTasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<CreateTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        await createTask.execute(event.task);
        if (event.allPlantIds != null && event.allPlantIds!.isNotEmpty) {
          final List<Task> allTasks = [];
          for (final plantId in event.allPlantIds!) {
            final tasks = await getTasks.execute(plantId);
            allTasks.addAll(tasks);
          }
          allTasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          emit(TaskLoaded(allTasks));
        } else {
          final tasks = await getTasks.execute(event.task.plantId);
          emit(TaskLoaded(tasks));
        }
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<CompleteTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        await repository.completeTask(event.taskId);
        if (event.allPlantIds != null && event.allPlantIds!.isNotEmpty) {
          final List<Task> allTasks = [];
          for (final plantId in event.allPlantIds!) {
            final tasks = await getTasks.execute(plantId);
            allTasks.addAll(tasks);
          }
          allTasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          emit(TaskLoaded(allTasks));
        } else {
          final tasks = await getTasks.execute(event.plantId);
          emit(TaskLoaded(tasks));
        }
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      emit(TaskLoading());
      try {
        await repository.deleteTask(event.taskId);
        if (event.allPlantIds != null && event.allPlantIds!.isNotEmpty) {
          final List<Task> allTasks = [];
          for (final plantId in event.allPlantIds!) {
            final tasks = await getTasks.execute(plantId);
            allTasks.addAll(tasks);
          }
          allTasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          emit(TaskLoaded(allTasks));
        } else {
          final tasks = await getTasks.execute(event.plantId);
          emit(TaskLoaded(tasks));
        }
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
  }
}

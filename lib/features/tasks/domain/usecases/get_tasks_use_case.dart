import '../models/task.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;
  GetTasksUseCase(this.repository);

  Future<List<Task>> execute(int plantId) {
    return repository.getPendingTasks(plantId);
  }

  Future<List<Task>> getHistory(int plantId) {
    return repository.getTaskHistory(plantId);
  }

  Future<List<Task>> getAll(int plantId) {
    return repository.getTasksByPlant(plantId);
  }
}

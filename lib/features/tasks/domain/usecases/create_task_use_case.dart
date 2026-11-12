import '../models/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);

  Future<Task> execute(Task task) {
    return repository.createTask(task);
  }
}

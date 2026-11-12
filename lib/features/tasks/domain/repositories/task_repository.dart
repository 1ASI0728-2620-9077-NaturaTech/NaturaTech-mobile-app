import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasksByPlant(int plantId);
  Future<List<Task>> getPendingTasks(int plantId);
  Future<List<Task>> getTaskHistory(int plantId);
  Future<Task> createTask(Task task);
  Future<Task> completeTask(int taskId, {int? humidity, String? notes});
  Future<void> deleteTask(int taskId);
}

import 'package:flutter/material.dart';
import '../../domain/models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onComplete;

  const TaskListItem({required this.task, this.onComplete, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWatering = task.action == 'WATER';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          isWatering ? Icons.water_drop : Icons.eco,
          color: isWatering ? Colors.blue : Colors.green,
        ),
        title: Text(task.action),
        subtitle: Text("Programado: ${task.scheduledDate}"),
        trailing: task.isCompleted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: onComplete,
              ),
      ),
    );
  }
}

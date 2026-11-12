import '../../domain/models/task.dart';

class TaskDto {
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt() ?? 0,
      action: json['action']?.toString() ?? '',
      scheduledDate: json['scheduledDate']?.toString() ?? '',
      completedAt: json['completedAt']?.toString(),
      plantId: json['plantId'] is int
          ? json['plantId']
          : (json['plantId'] as num?)?.toInt() ?? 0,
      profileId: json['profileId'] is int
          ? json['profileId']
          : (json['profileId'] as num?)?.toInt() ?? 0,
      humidity: json['humidity'] as int?,
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
    );
  }

  static Map<String, dynamic> toCreateJson(Task task) {
    return {
      'action': task.action,
      'scheduledDate': task.scheduledDate,
      'plantId': task.plantId,
      'profileId': task.profileId,
      if (task.humidity != null) 'humidity': task.humidity,
      if (task.notes != null && task.notes!.isNotEmpty) 'notes': task.notes,
    };
  }
}

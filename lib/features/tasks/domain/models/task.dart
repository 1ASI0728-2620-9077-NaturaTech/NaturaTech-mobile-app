import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String action;
  final String scheduledDate;
  final String? completedAt;
  final int plantId;
  final int profileId;
  final int? humidity;
  final String? notes;
  final String status; // PENDING, COMPLETED

  const Task({
    required this.id,
    required this.action,
    required this.scheduledDate,
    this.completedAt,
    required this.plantId,
    required this.profileId,
    this.humidity,
    this.notes,
    this.status = 'PENDING',
  });

  bool get isCompleted => status == 'COMPLETED';

  @override
  List<Object?> get props =>
      [id, action, scheduledDate, plantId, profileId, status];
}

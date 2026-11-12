import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/task.dart';
import '../blocs/task_bloc.dart';
import '../blocs/task_event.dart';
import '../blocs/task_state.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/services/notification_service.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../plants/domain/repositories/plant_repository.dart';
import '../../../plants/domain/models/plant.dart';

class CalendarTasksPage extends StatefulWidget {
  final int? plantId;
  final int? profileId;
  final bool viewOnly;

  const CalendarTasksPage({
    this.plantId,
    this.profileId,
    this.viewOnly = false,
    super.key,
  });

  @override
  State<CalendarTasksPage> createState() => _CalendarTasksPageState();
}

class _CalendarTasksPageState extends State<CalendarTasksPage> {
  int? _profileId;
  List<Plant> _userPlants = [];
  bool _isFromBottomNav = false;
  bool _initialLoading = true;

  static const List<Color> _plantColors = [
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFFFF3E0),
    Color(0xFFE0F7FA),
    Color(0xFFF1F8E9),
    Color(0xFFE8EAF6),
    Color(0xFFFFF9C4),
    Color(0xFFEFEBE9),
  ];

  static const List<Color> _plantColorsDark = [
    Color(0xFF1B5E20),
    Color(0xFF0D47A1),
    Color(0xFFE65100),
    Color(0xFF006064),
    Color(0xFF33691E),
    Color(0xFF1A237E),
    Color(0xFFF57F17),
    Color(0xFF3E2723),
  ];

  @override
  void initState() {
    super.initState();
    _isFromBottomNav = widget.plantId == null;

    if (_isFromBottomNav) {
      _loadProfileAndTasks();
    } else {
      _initialLoading = false;
      _profileId = widget.profileId;
      context.read<TaskBloc>().add(LoadTasks(widget.plantId!));
    }
  }

  Color _getPlantColor(int plantId) {
    final index = _userPlants.indexWhere((p) => p.id == plantId);
    final i = index >= 0 ? index : plantId;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? _plantColorsDark : _plantColors;
    return colors[i % colors.length];
  }

  Future<void> _loadProfileAndTasks() async {
    final sessionManager = sl<SessionManager>();
    final userId = await sessionManager.getUserId();
    if (userId == null) return;

    try {
      final profileRepo = sl<ProfileRepository>();
      final profile = await profileRepo.getProfileByUserId(userId);
      _profileId = profile.id;
    } catch (e) {
      _profileId = userId;
    }

    if (!mounted || _profileId == null) return;

    try {
      final plantRepo = sl<PlantRepository>();
      final plants = await plantRepo.getPlantsByProfile(_profileId!);
      if (mounted) {
        setState(() {
          _userPlants = plants;
          _initialLoading = false;
        });
        if (plants.isNotEmpty) {
          final plantIds = plants.map((p) => p.id).toList();
          context.read<TaskBloc>().add(LoadAllPlantsTasks(plantIds));
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _initialLoading = false);
      }
    }
  }

  List<int> get _allPlantIds => _userPlants.map((p) => p.id).toList();

  void _showCreateTaskDialog() {
    if (_profileId == null || _userPlants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Primero registra una planta para crear tareas")),
      );
      return;
    }

    final actionController = TextEditingController();
    final notesController = TextEditingController();
    int selectedPlantId = _userPlants.first.id;
    DateTime scheduledDate = DateTime.now();

    String formatDate(DateTime d) {
      return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Nueva Tarea"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: actionController,
                  decoration: InputDecoration(
                    labelText: "Nombre de la accion",
                    hintText: "Ej. Regar, Fertilizar, Podar...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.task_alt),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: selectedPlantId,
                  decoration: InputDecoration(
                    labelText: "Planta",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.eco),
                  ),
                  items: _userPlants
                      .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name,
                              overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedPlantId = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: scheduledDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => scheduledDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Fecha programada",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(formatDate(scheduledDate)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Notas (opcional)",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32)),
              onPressed: () {
                if (actionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Ingresa el nombre de la accion')),
                  );
                  return;
                }
                final taskAction = actionController.text.trim();
                final task = Task(
                  id: 0,
                  action: taskAction,
                  scheduledDate: formatDate(scheduledDate),
                  plantId: selectedPlantId,
                  profileId: _profileId!,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                );
                context.read<TaskBloc>().add(
                    CreateTaskEvent(task, allPlantIds: _allPlantIds));

                final plantName = _getPlantNameById(selectedPlantId) ?? 'Planta';
                final now = DateTime.now();
                final isToday = scheduledDate.year == now.year &&
                    scheduledDate.month == now.month &&
                    scheduledDate.day == now.day;

                if (isToday) {
                  NotificationService.showTaskNotification(
                    taskId: now.millisecondsSinceEpoch ~/ 1000,
                    action: taskAction,
                    plantName: plantName,
                  );
                } else {
                  NotificationService.scheduleTaskNotification(
                    taskId: now.millisecondsSinceEpoch ~/ 1000,
                    action: taskAction,
                    plantName: plantName,
                    scheduledDate: scheduledDate,
                  );
                }

                Navigator.pop(ctx);
              },
              child: const Text("Crear",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _getTaskLabel(String action) {
    switch (action.toUpperCase()) {
      case 'WATER':
        return 'Regar';
      case 'SUNLIGHT':
        return 'Exponer al sol';
      case 'FERTILIZE':
        return 'Fertilizar';
      case 'PRUNE':
        return 'Podar';
      default:
        return action;
    }
  }

  IconData _getTaskIcon(String action) {
    switch (action.toUpperCase()) {
      case 'WATER':
        return Icons.water_drop;
      case 'SUNLIGHT':
        return Icons.wb_sunny;
      case 'FERTILIZE':
        return Icons.eco;
      case 'PRUNE':
        return Icons.content_cut;
      default:
        return Icons.task;
    }
  }

  Color _getTaskIconColor(String action) {
    switch (action.toUpperCase()) {
      case 'WATER':
        return Colors.blue;
      case 'SUNLIGHT':
        return Colors.orange;
      case 'FERTILIZE':
        return Colors.green;
      case 'PRUNE':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String? _getPlantNameById(int plantId) {
    try {
      return _userPlants.firstWhere((p) => p.id == plantId).name;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle =
        widget.viewOnly ? 'Historial de Tareas' : 'Mis Tareas';

    if (_initialLoading) {
      return Scaffold(
        appBar: _isFromBottomNav
            ? AppBar(title: const Text('Mis Tareas'))
            : AppBar(title: Text(appBarTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _isFromBottomNav
          ? AppBar(title: const Text('Mis Tareas'))
          : AppBar(title: Text(appBarTitle)),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            );
          }
          if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 80, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      widget.viewOnly
                          ? "No hay tareas registradas"
                          : "No hay tareas pendientes",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_isFromBottomNav) ...[
                      const SizedBox(height: 8),
                      const Text("Toca + para crear una tarea",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                final plantName = _getPlantNameById(task.plantId);
                final cardColor = _isFromBottomNav
                    ? _getPlantColor(task.plantId)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]!
                        : Colors.grey[100]!);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(_getTaskIcon(task.action),
                          color: _getTaskIconColor(task.action), size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTaskLabel(task.action),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (plantName != null)
                              Text(
                                plantName,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              "Programada: ${task.scheduledDate}",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600]),
                            ),
                            if (task.notes != null &&
                                task.notes!.isNotEmpty)
                              Text(task.notes!,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (!widget.viewOnly) ...[
                        if (!task.isCompleted) ...[
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline,
                                color: Colors.green),
                            onPressed: () {
                              context.read<TaskBloc>().add(
                                CompleteTaskEvent(
                                  task.id,
                                  task.plantId,
                                  allPlantIds: _isFromBottomNav
                                      ? _allPlantIds
                                      : null,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              context.read<TaskBloc>().add(
                                DeleteTaskEvent(
                                  task.id,
                                  task.plantId,
                                  allPlantIds: _isFromBottomNav
                                      ? _allPlantIds
                                      : null,
                                ),
                              );
                            },
                          ),
                        ] else
                          const Icon(Icons.check_circle,
                              color: Colors.green),
                      ] else ...[
                        if (task.isCompleted)
                          const Icon(Icons.check_circle,
                              color: Colors.green)
                        else
                          const Icon(Icons.schedule,
                              color: Colors.orange),
                      ],
                    ],
                  ),
                );
              },
            );
          }
          if (_isFromBottomNav && _userPlants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Registra una planta primero",
                      style:
                          TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: _isFromBottomNav
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2E7D32),
              onPressed: _showCreateTaskDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

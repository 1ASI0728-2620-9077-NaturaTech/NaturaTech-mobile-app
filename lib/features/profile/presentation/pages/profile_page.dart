import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../auth/presentation/blocs/auth_event.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/models/profile.dart';
import '../blocs/profile_bloc.dart';
import '../blocs/profile_event.dart';
import '../blocs/profile_state.dart';
import '../pages/edit_profile_page.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/services/notification_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final enabled = await NotificationService.isEnabled();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _toggleNotifications(bool val) async {
    if (val) {
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de notificaciones denegado')),
          );
        }
        return;
      }
    }
    await NotificationService.setEnabled(val);
    if (mounted) setState(() => _notificationsEnabled = val);
  }

  Future<void> _loadProfile() async {
    final sessionManager = sl<SessionManager>();
    final userId = await sessionManager.getUserId();
    _email = await sessionManager.getEmail();
    if (userId != null && mounted) {
      context.read<ProfileBloc>().add(LoadProfile(userId));
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text("Reintentar"),
                  ),
                ],
              ),
            );
          }
          if (state is ProfileLoaded) {
            return _buildProfileContent(state.profile);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildProfileContent(Profile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.person, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text("Informacion de Perfil",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF1976D2)),
            title: const Text("Nombre",
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(profile.fullName),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.email, color: Color(0xFFD32F2F)),
            title: const Text("Email",
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_email ?? ''),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditProfilePage(currentProfile: profile, email: _email ?? ''),
              ),
            ).then((result) {
              if (result == true) _loadProfile();
            });
          },
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text("Editar Perfil",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        const Text("Plan de Suscripcion",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: _getPlanColor(profile.subscriptionPlan),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Plan Actual: ${profile.subscriptionPlan}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => _showChangePlanDialog(context, profile),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00897B),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00897B).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.shopping_cart,
                    color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        const Text("Notificaciones",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading:
                const Icon(Icons.notifications, color: Color(0xFFF57C00)),
            title: const Text("Notificaciones de Tareas",
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Recibe recordatorios de cuidado"),
            trailing: Switch(
              activeThumbColor: const Color(0xFFF57C00),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan) {
      case 'PREMIUM':
        return Colors.amber;
      case 'PRO':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void _showChangePlanDialog(BuildContext context, Profile profile) {
    String selectedPlan = profile.subscriptionPlan;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Elige tu plan:"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPlanOption('BASIC', Colors.green,
                    ['Registro de plantas', 'Recordatorio de cuidado', 'Monitoreo Manual'],
                    selectedPlan, (p) => setState(() => selectedPlan = p)),
                const SizedBox(height: 12),
                _buildPlanOption('PREMIUM', Colors.amber,
                    ['Todo del Basico', 'Calendario de tareas', 'Guias y cuidados'],
                    selectedPlan, (p) => setState(() => selectedPlan = p)),
                const SizedBox(height: 12),
                _buildPlanOption('PRO', Colors.orange,
                    ['Todo del Premium', 'Historial completo', 'IoT avanzado'],
                    selectedPlan, (p) => setState(() => selectedPlan = p)),
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
                  backgroundColor: const Color(0xFF0277BD)),
              onPressed: () {
                final updated = Profile(
                  id: profile.id,
                  fullName: profile.fullName,
                  subscriptionPlan: selectedPlan,
                  userId: profile.userId,
                );
                context
                    .read<ProfileBloc>()
                    .add(UpdateProfileEvent(profile.id, updated));
                Navigator.pop(ctx);
              },
              child: const Text("Cambiar Plan",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(String planName, Color color, List<String> features,
      String selectedPlan, Function(String) onSelect) {
    bool isSelected = selectedPlan == planName;
    return GestureDetector(
      onTap: () => onSelect(planName),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(
              color: isSelected ? color : Colors.grey,
              width: isSelected ? 3 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(planName,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: color)),
                const Spacer(),
                Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? color : Colors.grey),
              ],
            ),
            const SizedBox(height: 8),
            ...features.map((f) => Text('- $f', style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cerrar Sesion"),
        content: const Text("Estas seguro de que deseas cerrar sesion?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828)),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Cerrar Sesion",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

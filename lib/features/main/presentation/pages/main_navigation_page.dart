import 'package:flutter/material.dart';
import '../../../plants/presentation/pages/plant_dashboard_page.dart';
import '../../../tasks/presentation/pages/calendar_tasks_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return const PlantDashboardPage();
      case 1:
        return const CalendarTasksPage();
      case 2:
        return const ProfilePage();
      default:
        return const PlantDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Plantas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Tareas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/services/service_locator.dart';
import 'core/services/notification_service.dart';
import 'core/ui/theme.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/plants/presentation/blocs/plant_bloc.dart';
import 'features/iot/presentation/blocs/iot_bloc.dart';
import 'features/tasks/presentation/blocs/task_bloc.dart';
import 'features/profile/presentation/blocs/profile_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await NotificationService.init();

  runApp(const BioDemeterApp());
}

class BioDemeterApp extends StatelessWidget {
  const BioDemeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<PlantBloc>(create: (_) => sl<PlantBloc>()),
        BlocProvider<IotBloc>(create: (_) => sl<IotBloc>()),
        BlocProvider<TaskBloc>(create: (_) => sl<TaskBloc>()),
        BlocProvider<ProfileBloc>(create: (_) => sl<ProfileBloc>()),
      ],
      child: MaterialApp(
        title: 'PlantSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, 
        home: LoginPage(),
      ),
    );
  }
}
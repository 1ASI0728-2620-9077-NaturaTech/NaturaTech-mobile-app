import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'session_manager.dart';
import 'secure_key_manager.dart';
import '../network/dio_interceptor.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/plants/domain/repositories/plant_repository.dart';
import '../../features/plants/data/repositories/plant_repository_impl.dart';
import '../../features/iot/domain/repositories/iot_repository.dart';
import '../../features/iot/data/repositories/iot_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';

import '../../features/auth/domain/usecases/sign_in_use_case.dart';
import '../../features/auth/domain/usecases/sign_up_use_case.dart';
import '../../features/plants/domain/usecases/get_plants_use_case.dart';
import '../../features/plants/domain/usecases/create_plant_use_case.dart';
import '../../features/plants/domain/usecases/delete_plant_use_case.dart';
import '../../features/plants/domain/usecases/update_plant_use_case.dart';
import '../../features/iot/domain/usecases/get_latest_reading_use_case.dart';
import '../../features/iot/domain/usecases/trigger_actuator_use_case.dart';
import '../../features/tasks/domain/usecases/get_tasks_use_case.dart';
import '../../features/tasks/domain/usecases/create_task_use_case.dart';
import '../../features/profile/domain/usecases/get_profile_use_case.dart';
import '../../features/profile/domain/usecases/update_profile_use_case.dart';

import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/plants/presentation/blocs/plant_bloc.dart';
import '../../features/iot/presentation/blocs/iot_bloc.dart';
import '../../features/tasks/presentation/blocs/task_bloc.dart';
import '../../features/profile/presentation/blocs/profile_bloc.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton(() => SessionManager());
  sl.registerLazySingleton(() => SecureKeyManager());

  sl.registerLazySingleton(() {
    final dio = Dio();
    dio.interceptors.add(DioInterceptor(sl<SessionManager>()));
    return dio;
  });

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<PlantRepository>(() => PlantRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton<IotRepository>(() => IotRepositoryImpl(sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GetPlantsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlantUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlantUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePlantUseCase(sl()));
  sl.registerLazySingleton(() => GetLatestReadingUseCase(sl()));
  sl.registerLazySingleton(() => TriggerActuatorUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));

  sl.registerFactory(() => AuthBloc(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        sessionManager: sl(),
      ));
  sl.registerFactory(() => PlantBloc(
        getPlants: sl(),
        createPlant: sl(),
        deletePlant: sl(),
        updatePlant: sl(),
        taskRepository: sl(),
      ));
  sl.registerFactory(() => IotBloc(sl()));
  sl.registerFactory(() => TaskBloc(
        getTasks: sl(),
        createTask: sl(),
        repository: sl(),
      ));
  sl.registerFactory(() => ProfileBloc(
        getProfile: sl(),
        updateProfile: sl(),
      ));
}

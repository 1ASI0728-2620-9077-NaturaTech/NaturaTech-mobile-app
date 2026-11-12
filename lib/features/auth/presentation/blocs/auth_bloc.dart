import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import '../../../../core/services/session_manager.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SessionManager sessionManager;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.sessionManager,
  }) : super(AuthInitial()) {
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInUseCase.execute(event.email, event.password);

        if (user.token.isNotEmpty) {
          await sessionManager.saveSession(
            token: user.token,
            userId: user.id,
            email: user.email,
          );
          debugPrint("LOGIN EXITOSO - userId: ${user.id}");
        }

        emit(Authenticated());
      } catch (e) {
        debugPrint("ERROR EN LOGIN: $e");
        emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await signUpUseCase.execute(
          event.name,
          event.email,
          event.password,
          event.subscriptionPlan,
        );
        emit(AuthInitial());
      } catch (e) {
        debugPrint("ERROR EN REGISTRO: $e");
        emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await sessionManager.logout();
      emit(AuthInitial());
    });
  }
}

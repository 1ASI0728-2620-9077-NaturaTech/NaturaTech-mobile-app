import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String subscriptionPlan;

  SignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    this.subscriptionPlan = 'BASIC',
  });

  @override
  List<Object?> get props => [name, email, password, subscriptionPlan];
}

class LogoutRequested extends AuthEvent {}

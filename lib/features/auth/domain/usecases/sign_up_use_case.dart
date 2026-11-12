import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<void> execute(String name, String email, String password, String subscriptionPlan) {
    return repository.signUp(name, email, password, subscriptionPlan);
  }
}

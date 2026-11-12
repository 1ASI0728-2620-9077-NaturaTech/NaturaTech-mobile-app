class SignInDto {
  final String email;
  final String password;

  SignInDto({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

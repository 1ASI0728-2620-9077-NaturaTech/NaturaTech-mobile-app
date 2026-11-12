class SignUpDto {
  final String name;
  final String email;
  final String password;
  final String subscriptionPlan;

  SignUpDto({
    required this.name,
    required this.email,
    required this.password,
    this.subscriptionPlan = 'BASIC',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'subscriptionPlan': subscriptionPlan,
    };
  }
}

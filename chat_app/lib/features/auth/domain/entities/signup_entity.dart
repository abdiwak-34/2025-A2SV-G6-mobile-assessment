class SignupData {
  final String name;
  final String email;
  final String password;

  const SignupData({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}
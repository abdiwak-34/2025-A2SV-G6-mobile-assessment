class LoginData {
  final String email;
  final String password;

  const LoginData({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
class CreateUserReq {
  final String username;
  final String email;
  final String password;
  CreateUserReq({
    required this.email,
    required this.password,
    required this.username,
  });
}

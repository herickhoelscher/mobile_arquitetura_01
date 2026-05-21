class UserEntity {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String image;

  UserEntity({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
  });

  String get fullName => '$firstName $lastName';
}

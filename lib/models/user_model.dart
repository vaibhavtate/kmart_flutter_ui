class UserModel {
  const UserModel({
    required this.id,
    this.phone,
    this.email,
    this.name,
  });

  final String id;
  final String? phone;
  final String? email;
  final String? name;

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      id: '${map['id']}',
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      name: map['name']?.toString(),
    );
  }
}
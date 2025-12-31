import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.name,
    super.email,
    super.role,
    super.twoFactorEnabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      twoFactorEnabled: json['two_factor_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'two_factor_enabled': twoFactorEnabled,
    };
  }
}

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String? name;
  final String? email;
  final String? role;
  final bool? twoFactorEnabled;

  const User({
    required this.id,
    this.name,
    this.email,
    this.role,
    this.twoFactorEnabled,
  });

  @override
  List<Object?> get props => [id, name, email, role, twoFactorEnabled];
}

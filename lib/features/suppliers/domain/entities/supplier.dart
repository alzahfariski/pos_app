import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final String name;
  final String? contact;

  const Supplier({required this.id, required this.name, this.contact});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contact: json['contact'],
    );
  }

  @override
  List<Object?> get props => [id, name, contact];
}

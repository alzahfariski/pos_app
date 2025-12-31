import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String sku;
  final String name;
  final double cost;
  final double price;
  final int stock;
  final String? imagePath;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.cost,
    required this.price,
    required this.stock,
    this.imagePath,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    sku,
    name,
    cost,
    price,
    stock,
    imagePath,
    imageUrl,
    createdAt,
    updatedAt,
  ];
}

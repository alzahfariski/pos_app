import 'package:equatable/equatable.dart';

class StockOpname extends Equatable {
  final int id;
  final int productId;
  final int systemStock;
  final int physicalStock;
  final int difference;
  final String note;
  final String productName;
  final String productSku;
  final String createdByName;
  final String createdAt;

  const StockOpname({
    required this.id,
    required this.productId,
    required this.systemStock,
    required this.physicalStock,
    required this.difference,
    required this.note,
    required this.productName,
    required this.productSku,
    required this.createdByName,
    required this.createdAt,
  });

  factory StockOpname.fromJson(Map<String, dynamic> json) {
    return StockOpname(
      id: json['id'],
      productId: json['product_id'],
      systemStock: json['system_stock'],
      physicalStock: json['physical_stock'],
      difference: json['difference'],
      note: json['note'] ?? '',
      productName: json['product']?['name'] ?? 'Unknown Product',
      productSku: json['product']?['sku'] ?? '',
      createdByName: json['created_by']?['name'] ?? 'Unknown User',
      createdAt: json['created_at'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    systemStock,
    physicalStock,
    difference,
    note,
    productName,
    productSku,
    createdByName,
    createdAt,
  ];
}

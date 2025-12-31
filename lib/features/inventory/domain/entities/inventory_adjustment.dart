import 'package:equatable/equatable.dart';

class InventoryAdjustment extends Equatable {
  final int id;
  final int productId;
  final int qtyChange;
  final String reason;
  final String productName;
  final String productSku;
  final String adjustedByName;
  final String createdAt;

  const InventoryAdjustment({
    required this.id,
    required this.productId,
    required this.qtyChange,
    required this.reason,
    required this.productName,
    required this.productSku,
    required this.adjustedByName,
    required this.createdAt,
  });

  factory InventoryAdjustment.fromJson(Map<String, dynamic> json) {
    return InventoryAdjustment(
      id: json['id'],
      productId: json['product_id'],
      qtyChange: json['qty_change'],
      reason: json['reason'] ?? '',
      productName: json['product']?['name'] ?? 'Unknown Product',
      productSku: json['product']?['sku'] ?? '',
      adjustedByName: json['adjusted_by']?['name'] ?? 'Unknown User',
      createdAt: json['created_at'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    qtyChange,
    reason,
    productName,
    productSku,
    adjustedByName,
    createdAt,
  ];
}

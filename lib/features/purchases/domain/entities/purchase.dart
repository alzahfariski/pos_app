import 'package:equatable/equatable.dart';

class PurchaseItem extends Equatable {
  final int id;
  final int productId;
  final int quantity;
  final int cost;
  final String productName;

  const PurchaseItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.cost,
    required this.productName,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 0,
      cost: json['cost'] ?? 0,
      productName: json['product']?['name'] ?? 'Unknown Product',
    );
  }

  @override
  List<Object?> get props => [id, productId, quantity, cost, productName];
}

class Purchase extends Equatable {
  final int id;
  final int supplierId;
  final int totalCost;
  final String date;
  final String supplierName;
  final List<PurchaseItem> items;

  const Purchase({
    required this.id,
    required this.supplierId,
    required this.totalCost,
    required this.date,
    this.supplierName = '',
    this.items = const [],
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      supplierId: json['supplier_id'],
      totalCost: json['total_cost'] ?? 0,
      date: json['created_at'] ?? '',
      supplierName: json['supplier']?['name'] ?? 'Unknown Supplier',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => PurchaseItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    supplierId,
    totalCost,
    date,
    supplierName,
    items,
  ];
}

import 'package:equatable/equatable.dart';

class PosTransaction extends Equatable {
  final int id;
  final int totalAmount;
  final int paymentAmount;
  final int changeAmount;
  final String
  cashierName; // might be cashier_id or name from response? response says "cashier_id": 1. But typically we want name. The previous implementation had cashierName. The new response has cashier_id. I will keep cashierName but make it nullable or handle it. Wait, the response is: "cashier_id": 1. But previous was json['cashier']?['name'].
  // Just add new fields.
  final String paymentMethod;
  final String invoiceNumber;
  final String createdAt;
  final List<PosTransactionItem> items;

  const PosTransaction({
    required this.id,
    required this.totalAmount,
    required this.paymentAmount,
    required this.changeAmount,
    required this.cashierName,
    required this.paymentMethod,
    required this.invoiceNumber,
    required this.createdAt,
    required this.items,
  });

  factory PosTransaction.fromJson(Map<String, dynamic> json) {
    return PosTransaction(
      id: json['id'],
      totalAmount: json['total_amount'],
      paymentAmount: json['payment_amount'],
      changeAmount: json['change_amount'],
      cashierName: json['cashier'] != null
          ? json['cashier']['name']
          : (json['cashier_id']?.toString() ?? 'Unknown'),
      paymentMethod: json['payment_method'] ?? 'CASH',
      invoiceNumber: json['invoice_number'] ?? '',
      createdAt: json['created_at'],
      items:
          (json['items'] as List?)
              ?.map((e) => PosTransactionItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    totalAmount,
    paymentAmount,
    changeAmount,
    changeAmount,
    cashierName,
    paymentMethod,
    invoiceNumber,
    createdAt,
    items,
  ];
}

class PosTransactionItem extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final int qty;
  final int priceSnapshot;
  final int subtotal;

  const PosTransactionItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.priceSnapshot,
    required this.subtotal,
  });

  factory PosTransactionItem.fromJson(Map<String, dynamic> json) {
    return PosTransactionItem(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product']?['name'] ?? 'Unknown',
      qty: json['qty'],
      priceSnapshot: json['price_snapshot'],
      subtotal: json['subtotal'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    qty,
    priceSnapshot,
    subtotal,
  ];
}

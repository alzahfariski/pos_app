import 'package:equatable/equatable.dart';

class PurchaseItemInput extends Equatable {
  final int productId;
  final int quantity;
  final int cost;

  const PurchaseItemInput({
    required this.productId,
    required this.quantity,
    required this.cost,
  });

  @override
  List<Object> get props => [productId, quantity, cost];

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity, 'cost': cost};
  }
}

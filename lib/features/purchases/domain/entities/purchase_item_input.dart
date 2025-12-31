import 'package:equatable/equatable.dart';

class PurchaseItemInput extends Equatable {
  final int productId;
  final int quantity;

  const PurchaseItemInput({required this.productId, required this.quantity});

  @override
  List<Object> get props => [productId, quantity];

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity};
  }
}

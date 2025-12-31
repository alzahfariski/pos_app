import '../entities/purchase.dart';
import '../entities/purchase_item_input.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases();
  Future<void> createPurchase({
    required int supplierId,
    required List<PurchaseItemInput> items,
  });
}

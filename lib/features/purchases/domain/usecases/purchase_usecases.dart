import '../repositories/purchase_repository.dart';
import '../entities/purchase.dart';
import '../entities/purchase_item_input.dart';

class GetPurchasesUseCase {
  final PurchaseRepository repository;
  GetPurchasesUseCase(this.repository);
  Future<List<Purchase>> call() => repository.getPurchases();
}

class CreatePurchaseUseCase {
  final PurchaseRepository repository;
  CreatePurchaseUseCase(this.repository);
  Future<void> call({
    required int supplierId,
    required List<PurchaseItemInput> items,
  }) => repository.createPurchase(supplierId: supplierId, items: items);
}

import '../../domain/entities/purchase.dart';
import '../../domain/entities/purchase_item_input.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../data/datasources/purchase_remote_data_source.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseRemoteDataSource remoteDataSource;

  PurchaseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Purchase>> getPurchases() async {
    final data = await remoteDataSource.getPurchases();
    return data.map((json) => Purchase.fromJson(json)).toList();
  }

  @override
  Future<void> createPurchase({
    required int supplierId,
    required List<PurchaseItemInput> items,
  }) async {
    final data = {
      'supplier_id': supplierId,
      'items': items.map((item) => item.toJson()).toList(),
    };
    await remoteDataSource.createPurchase(data);
  }
}

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/pos_transaction.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/pos_remote_data_source.dart';

class PosRepositoryImpl implements PosRepository {
  final PosRemoteDataSource remoteDataSource;

  PosRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> processSale(
    int paymentAmount,
    List<CartItem> items,
    String paymentMethod,
  ) async {
    final itemsData = items.map((item) {
      return {"product_id": item.product.id, "qty": item.quantity};
    }).toList();

    final result = await remoteDataSource.processSale(
      paymentAmount: paymentAmount,
      items: itemsData,
      paymentMethod: paymentMethod,
    );

    // Fetch full details using the returned ID
    if (result.containsKey('id')) {
      final transactionId = result['id'] as int;
      return await remoteDataSource.getTransaction(transactionId);
    }

    return result;
  }

  @override
  Future<List<PosTransaction>> getPosHistory() async {
    final data = await remoteDataSource.getPosHistory();
    return data.map((json) => PosTransaction.fromJson(json)).toList();
  }
}

import '../entities/cart_item.dart';
import '../entities/pos_transaction.dart';

abstract class PosRepository {
  Future<Map<String, dynamic>> processSale(
    int paymentAmount,
    List<CartItem> items,
    String paymentMethod,
  );
  Future<List<PosTransaction>> getPosHistory();
}

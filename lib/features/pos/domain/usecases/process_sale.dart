import '../entities/cart_item.dart';
import '../repositories/pos_repository.dart';

class ProcessSaleUseCase {
  final PosRepository repository;

  ProcessSaleUseCase(this.repository);

  Future<Map<String, dynamic>> call(
    int paymentAmount,
    List<CartItem> items,
    String paymentMethod,
  ) async {
    return await repository.processSale(paymentAmount, items, paymentMethod);
  }
}

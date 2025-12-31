import '../entities/product.dart';
import '../repositories/products_repository.dart';

class AddProductUseCase {
  final ProductsRepository repository;

  AddProductUseCase(this.repository);

  Future<Product> call({
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  }) async {
    return await repository.addProduct(
      name: name,
      sku: sku,
      cost: cost,
      price: price,
      stock: stock,
    );
  }
}

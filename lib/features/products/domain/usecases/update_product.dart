import '../entities/product.dart';
import '../repositories/products_repository.dart';

class UpdateProductUseCase {
  final ProductsRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Product> call({
    required int id,
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  }) async {
    return await repository.updateProduct(
      id: id,
      name: name,
      sku: sku,
      cost: cost,
      price: price,
      stock: stock,
    );
  }
}

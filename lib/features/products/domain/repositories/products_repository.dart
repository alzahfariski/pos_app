import '../entities/product.dart';

abstract class ProductsRepository {
  Future<List<Product>> getProducts();

  Future<Product> addProduct({
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  });

  Future<Product> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  });

  Future<void> deleteProduct(int id);

  Future<Product> uploadProductImage(int id, String filePath);
}

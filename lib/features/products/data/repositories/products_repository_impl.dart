import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  }) async {
    return await remoteDataSource.addProduct(
      name: name,
      sku: sku,
      cost: cost,
      price: price,
      stock: stock,
    );
  }

  @override
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  }) async {
    return await remoteDataSource.updateProduct(
      id: id,
      name: name,
      sku: sku,
      cost: cost,
      price: price,
      stock: stock,
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    await remoteDataSource.deleteProduct(id);
  }

  @override
  Future<Product> uploadProductImage(int id, String filePath) async {
    return await remoteDataSource.uploadProductImage(id, filePath);
  }
}

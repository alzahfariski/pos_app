import '../entities/product.dart';
import '../repositories/products_repository.dart';

class UploadProductImageUseCase {
  final ProductsRepository repository;

  UploadProductImageUseCase(this.repository);

  Future<Product> call(int id, String filePath) async {
    return await repository.uploadProductImage(id, filePath);
  }
}

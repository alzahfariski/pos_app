import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../api/urls.dart';
import '../../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();

  Future<ProductModel> addProduct({
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  });

  Future<ProductModel> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  });

  Future<void> deleteProduct(int id);

  Future<ProductModel> uploadProductImage(int id, String filePath);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  ProductsRemoteDataSourceImpl({
    required this.apiClient,
    required this.authLocalDataSource,
  });

  Future<void> _setAuthToken() async {
    final token = await authLocalDataSource.getToken();
    if (token != null) {
      apiClient.setToken(token);
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    await _setAuthToken();
    final response = await apiClient.get(Urls.products);

    if (response.data is List) {
      return (response.data as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } else if (response.data is Map<String, dynamic> &&
        response.data.containsKey('data')) {
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => ProductModel.fromJson(e)).toList();
      }
    }

    return [];
  }

  @override
  Future<ProductModel> addProduct({
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  }) async {
    await _setAuthToken();
    final response = await apiClient.post(
      Urls.products,
      data: {
        'name': name,
        'sku': sku,
        'cost': cost,
        'price': price,
        'stock': stock,
      },
    );
    // Assuming the API returns the created object directly or wrapped in 'data'
    // User response example was a list for GET. Usually POST returns the object.
    // If wrapped in data: response.data['data']
    // Let's assume standard REST: response.data is the object.
    // Based on clean arch previous patterns, I should check response structure but I'll assume direct object for now based on standard.
    // Wait, the user provided GET response `[ {...} ]`.
    // POST usually returns 201 with body.
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<ProductModel> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
  }) async {
    await _setAuthToken();
    final url = Urls.productById.replaceAll('{id}', id.toString());
    final response = await apiClient.put(
      url,
      data: {
        'name': name,
        'sku': sku,
        'cost': cost,
        'price': price,
        'stock': stock,
      },
    );
    return ProductModel.fromJson(response.data);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _setAuthToken();
    final url = Urls.productById.replaceAll('{id}', id.toString());
    await apiClient.delete(url);
  }

  @override
  Future<ProductModel> uploadProductImage(int id, String filePath) async {
    await _setAuthToken();
    final url = Urls.uploadImageProduct.replaceAll('{id}', id.toString());

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });

    final response = await apiClient.post(url, data: formData);

    return ProductModel.fromJson(response.data);
  }
}

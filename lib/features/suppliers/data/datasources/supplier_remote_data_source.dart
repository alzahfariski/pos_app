import '../../../../core/network/api_client.dart';
import '../../../../api/urls.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class SupplierRemoteDataSource {
  Future<List<dynamic>> getSuppliers();
  Future<void> createSupplier(Map<String, dynamic> data);
  Future<void> updateSupplier(int id, Map<String, dynamic> data);
  Future<void> deleteSupplier(int id);
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  SupplierRemoteDataSourceImpl({
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
  Future<List<dynamic>> getSuppliers() async {
    await _setAuthToken();
    final response = await apiClient.get(Urls.suppliers);

    if (response.data is List) {
      return response.data;
    } else if (response.data is Map && response.data.containsKey('data')) {
      return response.data['data'];
    } else {
      return [];
    }
  }

  @override
  Future<void> createSupplier(Map<String, dynamic> data) async {
    await _setAuthToken();
    await apiClient.post(Urls.suppliers, data: data);
  }

  @override
  Future<void> updateSupplier(int id, Map<String, dynamic> data) async {
    await _setAuthToken();
    // Use replacement logic for ID
    final url = Urls.supplierById.replaceAll('{id}', id.toString());
    await apiClient.put(url, data: data);
  }

  @override
  Future<void> deleteSupplier(int id) async {
    await _setAuthToken();
    final url = Urls.supplierById.replaceAll('{id}', id.toString());
    await apiClient.delete(url);
  }
}

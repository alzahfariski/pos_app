import '../../../../core/network/api_client.dart';
import '../../../../api/urls.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class InventoryRemoteDataSource {
  Future<void> adjustStock(Map<String, dynamic> data);
  Future<void> stockOpname(Map<String, dynamic> data);
  Future<List<dynamic>> getAdjustments();
  Future<List<dynamic>> getStockOpnames();
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  InventoryRemoteDataSourceImpl({
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
  Future<void> adjustStock(Map<String, dynamic> data) async {
    await _setAuthToken();
    await apiClient.post(Urls.inventoryAdjustments, data: data);
  }

  @override
  Future<void> stockOpname(Map<String, dynamic> data) async {
    await _setAuthToken();
    await apiClient.post(Urls.inventoryOpname, data: data);
  }

  @override
  Future<List<dynamic>> getAdjustments() async {
    await _setAuthToken();
    final response = await apiClient.get(Urls.inventoryAdjustments);
    return response.data;
  }

  @override
  Future<List<dynamic>> getStockOpnames() async {
    await _setAuthToken();
    final response = await apiClient.get(Urls.inventoryOpname);
    return response.data;
  }
}

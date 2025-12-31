import '../../../../core/network/api_client.dart';
import '../../../../api/urls.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class PurchaseRemoteDataSource {
  Future<List<dynamic>> getPurchases();
  Future<void> createPurchase(Map<String, dynamic> data);
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  PurchaseRemoteDataSourceImpl({
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
  Future<List<dynamic>> getPurchases() async {
    await _setAuthToken();
    final response = await apiClient.get('${Urls.baseUrl}/purchases');

    // Check if response data is list or map with data key
    if (response.data is List) {
      return response.data;
    } else if (response.data is Map && response.data['data'] is List) {
      return response.data['data'];
    }
    return [];
  }

  @override
  Future<void> createPurchase(Map<String, dynamic> data) async {
    await _setAuthToken();
    await apiClient.post('${Urls.baseUrl}/purchases', data: data);
  }
}

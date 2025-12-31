import '../../../../core/network/api_client.dart';
import '../../../../api/urls.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/data/models/user_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserModel>> getCashiers();
  Future<void> createCashier(Map<String, dynamic> data);
  Future<void> updateCashier(int id, Map<String, dynamic> data);
  Future<void> deleteCashier(int id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  AdminRemoteDataSourceImpl({
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
  Future<List<UserModel>> getCashiers() async {
    await _setAuthToken();
    final response = await apiClient.get(Urls.cashiers);

    // Handle direct list response or wrapped data
    final dynamic responseData = response.data;
    List data = [];
    if (responseData is List) {
      data = responseData;
    } else if (responseData is Map && responseData['data'] is List) {
      data = responseData['data'];
    }

    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<void> createCashier(Map<String, dynamic> data) async {
    await _setAuthToken();
    await apiClient.post(Urls.cashiers, data: data);
  }

  @override
  Future<void> updateCashier(int id, Map<String, dynamic> data) async {
    await _setAuthToken();
    final url = Urls.cashierById.replaceAll('{id}', id.toString());
    await apiClient.put(url, data: data);
  }

  @override
  Future<void> deleteCashier(int id) async {
    await _setAuthToken();
    final url = Urls.cashierById.replaceAll('{id}', id.toString());
    await apiClient.delete(url);
  }
}

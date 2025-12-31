import '../../../../core/network/api_client.dart';
import '../../../../api/urls.dart';
import '../../../auth/data/datasources/auth_local_data_source.dart';

abstract class PosRemoteDataSource {
  Future<Map<String, dynamic>> processSale({
    required int paymentAmount,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
  });
  Future<Map<String, dynamic>> getTransaction(int id);
  Future<List<dynamic>> getPosHistory();
}

class PosRemoteDataSourceImpl implements PosRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  PosRemoteDataSourceImpl({
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
  Future<Map<String, dynamic>> processSale({
    required int paymentAmount,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
  }) async {
    await _setAuthToken();
    final response = await apiClient.post(
      Urls.pos,
      data: {
        'payment_amount': paymentAmount,
        'items': items,
        'payment_method': paymentMethod,
      },
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getTransaction(int id) async {
    await _setAuthToken();
    final url = Urls.transactionById.replaceAll('{id}', id.toString());
    final response = await apiClient.get(url);
    return response.data;
  }

  @override
  Future<List<dynamic>> getPosHistory() async {
    await _setAuthToken();
    final response = await apiClient.get(Urls.pos);
    return response.data;
  }
}

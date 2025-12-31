import '../../../../core/network/api_client.dart';
import '../../../../api/urls.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required int userId,
    required String otp,
    required String deviceName,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<void> forgotPassword(String email);

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  Future<UserModel> updateProfile({
    required String name,
    required String email,
  });

  Future<Map<String, dynamic>> loginGoogle(String idToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post(
      Urls.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await apiClient.post(
      Urls.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required int userId,
    required String otp,
    required String deviceName,
  }) async {
    final response = await apiClient.post(
      Urls.verifyOtp,
      data: {'user_id': userId, 'otp': otp, 'device_name': deviceName},
    );
    return response.data;
  }

  @override
  Future<void> logout() async {
    await apiClient.post(Urls.logout);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(Urls.getCurrentUser);
    // User response is direct JSON object as per example
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await apiClient.post(Urls.forgotPassword, data: {'email': email});
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await apiClient.post(
      Urls.updatePassword,
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final data = {'name': name, 'email': email};
    await apiClient.put(Urls.updateProfile, data: data);
    return getCurrentUser();
  }

  @override
  Future<Map<String, dynamic>> loginGoogle(String idToken) async {
    final response = await apiClient.post(
      Urls.loginGoogle,
      data: {'id_token': idToken, 'device_name': 'web'},
    );
    return response.data;
  }
}

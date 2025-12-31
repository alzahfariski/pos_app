import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await remoteDataSource.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> loginGoogle(String idToken) async {
    final response = await remoteDataSource.loginGoogle(idToken);

    // Check if login was successful and we got a token immediately (2FA OFF)
    if (response.containsKey('access_token')) {
      final token = response['access_token'];
      await localDataSource.cacheToken(token);
    }

    return response;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  @override
  Future<void> verifyOtp({
    required int userId,
    required String otp,
    required String deviceName,
  }) async {
    final response = await remoteDataSource.verifyOtp(
      userId: userId,
      otp: otp,
      deviceName: deviceName,
    );

    if (response.containsKey('access_token')) {
      final token = response['access_token'];
      await localDataSource.cacheToken(token);
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Set token if possible, or just call logout
      if (remoteDataSource is AuthRemoteDataSourceImpl) {
        final token = await localDataSource.getToken();
        if (token != null) {
          (remoteDataSource as AuthRemoteDataSourceImpl).apiClient.setToken(
            token,
          );
        }
      }
      await remoteDataSource.logout();
    } catch (_) {}
    await localDataSource.deleteToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null) {
        // Set token on the underlying client
        if (remoteDataSource is AuthRemoteDataSourceImpl) {
          (remoteDataSource as AuthRemoteDataSourceImpl).apiClient.setToken(
            token,
          );
        }
        return await remoteDataSource.getCurrentUser();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final token = await localDataSource.getToken();
    if (token != null) {
      if (remoteDataSource is AuthRemoteDataSourceImpl) {
        (remoteDataSource as AuthRemoteDataSourceImpl).apiClient.setToken(
          token,
        );
      }
      await remoteDataSource.updatePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final token = await localDataSource.getToken();
    if (token != null) {
      if (remoteDataSource is AuthRemoteDataSourceImpl) {
        (remoteDataSource as AuthRemoteDataSourceImpl).apiClient.setToken(
          token,
        );
      }
      return await remoteDataSource.updateProfile(name: name, email: email);
    }
    throw Exception('Not authenticated');
  }
}

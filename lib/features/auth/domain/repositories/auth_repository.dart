import '../entities/user.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);

  Future<Map<String, dynamic>> loginGoogle(String idToken);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> verifyOtp({
    required int userId,
    required String otp,
    required String deviceName,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

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
}

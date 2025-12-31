import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Map<String, dynamic>> call(String email, String password) {
    return repository.login(email, password);
  }
}

class LoginGoogleUseCase {
  final AuthRepository repository;

  LoginGoogleUseCase(this.repository);

  Future<Map<String, dynamic>> call(String idToken) {
    return repository.loginGoogle(idToken);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Map<String, dynamic>> call({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<void> call({
    required int userId,
    required String otp,
    required String deviceName,
  }) {
    return repository.verifyOtp(
      userId: userId,
      otp: otp,
      deviceName: deviceName,
    );
  }
}

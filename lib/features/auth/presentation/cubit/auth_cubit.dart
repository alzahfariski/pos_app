import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';

import 'package:google_sign_in/google_sign_in.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthRequiresTwoFactor extends AuthState {
  final int? userId;
  final String? tempToken;

  const AuthRequiresTwoFactor({this.userId, this.tempToken});

  @override
  List<Object?> get props => [userId, tempToken];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object> get props => [message];
}

class AuthOtpVerified extends AuthState {}

class AuthForgotPasswordSent extends AuthState {}

class AuthPasswordUpdated extends AuthAuthenticated {
  const AuthPasswordUpdated(super.user);
}

class AuthProfileUpdated extends AuthAuthenticated {
  const AuthProfileUpdated(super.user);
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LoginGoogleUseCase loginGoogleUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final AuthRepository authRepository;
  final GoogleSignIn googleSignIn;

  AuthCubit({
    required this.loginUseCase,
    required this.loginGoogleUseCase,
    required this.registerUseCase,
    required this.verifyOtpUseCase,
    required this.authRepository,
    required this.googleSignIn,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await loginUseCase(email, password);
      // Expected response: {"status": "2fa_required", "user_id": 1}
      if (response['status'] == '2fa_required') {
        final userId = response['user_id'];
        emit(AuthRequiresTwoFactor(userId: userId));
      } else {
        await checkAuthStatus();
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final account = await googleSignIn.signIn();

      if (account == null) {
        emit(AuthUnauthenticated()); // User cancelled
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        emit(const AuthFailure("Failed to retrieve Google ID Token"));
        return;
      }

      final response = await loginGoogleUseCase(idToken);

      // Case 2 — 2FA Required (OTP)
      if (response['status'] == '2fa_required') {
        final tempToken = response['temp_token'];
        // Note: Google login 2FA response has temp_token, not user_id usually.
        emit(AuthRequiresTwoFactor(tempToken: tempToken));
      } else {
        // Case 1 — Login Berhasil (2FA OFF)
        // Token is already cached by repository
        await checkAuthStatus();
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(AuthLoading());
    try {
      final response = await registerUseCase(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (response['status'] == '2fa_required') {
        final userId = response['user_id'];
        emit(AuthRequiresTwoFactor(userId: userId));
      } else {
        emit(const AuthFailure("Unexpected register response"));
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> verifyOtp(int userId, String otp) async {
    emit(AuthLoading());
    try {
      final deviceName = await _getDeviceName();
      await verifyOtpUseCase(userId: userId, otp: otp, deviceName: deviceName);
      // After verification, fetch user to update state
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthOtpVerified()); // Fallback if user fetch fails but OTP passed
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      await authRepository.forgotPassword(email);
      emit(AuthForgotPasswordSent());
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final currentUser = (state is AuthAuthenticated)
        ? (state as AuthAuthenticated).user
        : null;

    if (currentUser == null) return;

    emit(AuthLoading());
    try {
      await authRepository.updatePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      // Re-emit authenticated with the same user, but specialized state
      emit(AuthPasswordUpdated(currentUser));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      // Restore authenticated state if failed?
      emit(AuthAuthenticated(currentUser));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    emit(AuthLoading());
    try {
      final updatedUser = await authRepository.updateProfile(
        name: name,
        email: email,
      );
      emit(AuthProfileUpdated(updatedUser)); // Triggers success toast
      emit(AuthAuthenticated(updatedUser)); // Returns to stable state
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<String> _getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceName = "Unknown Device";

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      }
    } catch (_) {
      deviceName = "Flutter App";
    }
    return deviceName;
  }
}

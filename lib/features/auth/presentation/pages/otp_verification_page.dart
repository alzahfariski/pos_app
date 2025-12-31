import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../cubit/auth_cubit.dart';
import 'package:go_router/go_router.dart'; // Added for navigation
import '../../../../app/router/app_route_names.dart'; // Added for navigation

class OtpVerificationPage extends StatefulWidget {
  final int userId;
  const OtpVerificationPage({super.key, required this.userId});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if full
    String otp = _getOtp();
    if (otp.length == 6) {
      context.read<AuthCubit>().verifyOtp(widget.userId, otp);
    }
  }

  String _getOtp() {
    return _controllers.map((e) => e.text).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            CustomToast.show(context, state.message, isError: true);
            // Clear OTP on failure
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          } else if (state is AuthAuthenticated) {
            // Listen for Authenticated state
            CustomToast.show(
              context,
              'Verification Successful!',
              isError: false,
            );
            context.goNamed(AppRouteNames.dashboard);
          } else if (state is AuthOtpVerified) {
            // Fallback if AuthAuthenticated was not emitted but Verified was
            CustomToast.show(
              context,
              'Verification Successful!',
              isError: false,
            );
            context.goNamed(AppRouteNames.dashboard);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Custom Header with Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter the 6-digit code sent to your email to verify your identity.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // OTP Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 50,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _focusNodes[index].hasFocus
                                ? AppColors.primary500
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: _focusNodes[index].hasFocus
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary500.withAlpha(40),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) => _onOtpChanged(value, index),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 48),

                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final otp = _getOtp();
                            if (otp.length == 6) {
                              context.read<AuthCubit>().verifyOtp(
                                widget.userId,
                                otp,
                              );
                            } else {
                              CustomToast.show(
                                context,
                                'Please enter full 6-digit code',
                                isError: true,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Verify Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      // Logic to resend code
                      CustomToast.show(
                        context,
                        "Resend code feature coming soon",
                        isError: false,
                      );
                    },
                    child: const Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(
                        color: AppColors.primary500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

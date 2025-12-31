import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/app_route_names.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/products/presentation/pages/product_form_page.dart';
import '../../features/products/domain/entities/product.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: AppRouteNames.splash,
    routes: [
      GoRoute(
        path: AppRouteNames.splash,
        name: AppRouteNames.splash,
        builder: (BuildContext context, GoRouterState state) {
          return const SplashPage();
        },
      ),
      GoRoute(
        // Main Dashboard Entry
        path: AppRouteNames.dashboard,
        name: AppRouteNames.dashboard,
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardPage();
        },
      ),
      GoRoute(
        path: AppRouteNames.login,
        name: AppRouteNames.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: AppRouteNames.register,
        name: AppRouteNames.register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterPage();
        },
      ),
      GoRoute(
        path: AppRouteNames.otpVerification,
        name: AppRouteNames.otpVerification,
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          final userId = extra?['userId'] as int? ?? 0;
          return OtpVerificationPage(userId: userId);
        },
      ),
      GoRoute(
        path: AppRouteNames.productForm,
        name: AppRouteNames.productForm,
        builder: (BuildContext context, GoRouterState state) {
          final product = state.extra as Product?;
          return ProductFormPage(product: product);
        },
      ),
    ],
  );
}

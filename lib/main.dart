import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/app.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/products/presentation/cubit/products_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthCubit>()),
        BlocProvider(create: (context) => di.sl<ProductsCubit>()),
      ],
      child: const App(),
    ),
  );
}

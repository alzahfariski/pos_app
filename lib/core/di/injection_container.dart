import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/upload_product_image.dart';
import '../../features/products/domain/usecases/add_product.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/pos/presentation/cubit/pos_cubit.dart';
import '../../features/pos/presentation/cubit/pos_history_cubit.dart';
import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/admin_usecases.dart';
import '../../features/admin/presentation/cubit/cashier_cubit.dart';
import '../../features/suppliers/data/datasources/supplier_remote_data_source.dart';
import '../../features/suppliers/data/repositories/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repositories/supplier_repository.dart';
import '../../features/suppliers/domain/usecases/supplier_usecases.dart';
import '../../features/suppliers/presentation/cubit/supplier_cubit.dart';
import '../../features/purchases/data/datasources/purchase_remote_data_source.dart';
import '../../features/purchases/data/repositories/purchase_repository_impl.dart';
import '../../features/purchases/domain/repositories/purchase_repository.dart';
import '../../features/purchases/domain/usecases/purchase_usecases.dart';
import '../../features/purchases/presentation/cubit/purchase_cubit.dart';
import '../../features/pos/data/datasources/pos_remote_data_source.dart';
import '../../features/pos/data/repositories/pos_repository_impl.dart';
import '../../features/pos/domain/repositories/pos_repository.dart';
import '../../features/pos/domain/usecases/process_sale.dart';
import '../../features/inventory/data/datasources/inventory_remote_data_source.dart';

import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/presentation/cubit/inventory_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => GoogleSignIn(scopes: ['email']));

  // Features - Auth

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LoginGoogleUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  // Bloc/Cubit
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      loginGoogleUseCase: sl(),
      registerUseCase: sl(),
      verifyOtpUseCase: sl(),
      authRepository: sl(),
      googleSignIn: sl(),
    ),
  );

  // Feature: Products
  // Cubit
  sl.registerFactory(
    () => ProductsCubit(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
      uploadProductImageUseCase: sl(),
    ),
  );

  // Use Case
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => UploadProductImageUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(
      apiClient: sl(),
      authLocalDataSource: sl(),
    ),
  );
  // Feature: POS
  // Cubit
  sl.registerFactory(() => PosCubit(processSaleUseCase: sl()));
  sl.registerFactory(() => PosHistoryCubit(repository: sl()));

  // Use Case
  sl.registerLazySingleton(() => ProcessSaleUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<PosRemoteDataSource>(
    () => PosRemoteDataSourceImpl(apiClient: sl(), authLocalDataSource: sl()),
  );

  // Feature: Admin (Cashier Management)
  sl.registerFactory(
    () => CashierCubit(
      getCashiers: sl(),
      createCashier: sl(),
      updateCashier: sl(),
      deleteCashier: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCashiersUseCase(sl()));
  sl.registerLazySingleton(() => CreateCashierUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCashierUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCashierUseCase(sl()));

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(apiClient: sl(), authLocalDataSource: sl()),
  );

  // Feature: Suppliers
  sl.registerFactory(
    () => SupplierCubit(
      getSuppliers: sl(),
      createSupplier: sl(),
      updateSupplier: sl(),
      deleteSupplier: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetSuppliersUseCase(sl()));
  sl.registerLazySingleton(() => CreateSupplierUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSupplierUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSupplierUseCase(sl()));

  sl.registerLazySingleton<SupplierRepository>(
    () => SupplierRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SupplierRemoteDataSource>(
    () => SupplierRemoteDataSourceImpl(
      apiClient: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Feature: Purchases
  sl.registerFactory(
    () => PurchaseCubit(getPurchases: sl(), createPurchase: sl()),
  );

  sl.registerLazySingleton(() => GetPurchasesUseCase(sl()));
  sl.registerLazySingleton(() => CreatePurchaseUseCase(sl()));

  sl.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PurchaseRemoteDataSource>(
    () => PurchaseRemoteDataSourceImpl(
      apiClient: sl(),
      authLocalDataSource: sl(),
    ),
  );

  // Feature: Inventory Correction
  sl.registerFactory(() => InventoryCubit(repository: sl()));
  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(
      apiClient: sl(),
      authLocalDataSource: sl(),
    ),
  );
}

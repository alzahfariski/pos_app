import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<User>> getCashiers() async {
    return await remoteDataSource.getCashiers();
  }

  @override
  Future<void> createCashier(String name, String email, String password) async {
    await remoteDataSource.createCashier({
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password, // Send same password as confirmation
    });
  }

  @override
  Future<void> updateCashier(
    int id,
    String name,
    String email, {
    String? password,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'role': 'cashier', // Ensure role stays cashier
    };
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    await remoteDataSource.updateCashier(id, data);
  }

  @override
  Future<void> deleteCashier(int id) async {
    await remoteDataSource.deleteCashier(id);
  }
}

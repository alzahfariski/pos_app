import '../../../auth/domain/entities/user.dart';

abstract class AdminRepository {
  Future<List<User>> getCashiers();
  Future<void> createCashier(String name, String email, String password);
  Future<void> updateCashier(
    int id,
    String name,
    String email, {
    String? password,
  });
  Future<void> deleteCashier(int id);
}

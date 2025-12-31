import '../repositories/admin_repository.dart';
import '../../../auth/domain/entities/user.dart';

class GetCashiersUseCase {
  final AdminRepository repository;
  GetCashiersUseCase(this.repository);
  Future<List<User>> call() => repository.getCashiers();
}

class CreateCashierUseCase {
  final AdminRepository repository;
  CreateCashierUseCase(this.repository);
  Future<void> call(String name, String email, String password) =>
      repository.createCashier(name, email, password);
}

class UpdateCashierUseCase {
  final AdminRepository repository;
  UpdateCashierUseCase(this.repository);
  Future<void> call(int id, String name, String email, {String? password}) =>
      repository.updateCashier(id, name, email, password: password);
}

class DeleteCashierUseCase {
  final AdminRepository repository;
  DeleteCashierUseCase(this.repository);
  Future<void> call(int id) => repository.deleteCashier(id);
}

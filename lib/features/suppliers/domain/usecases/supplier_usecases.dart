import '../repositories/supplier_repository.dart';
import '../entities/supplier.dart';

class GetSuppliersUseCase {
  final SupplierRepository repository;
  GetSuppliersUseCase(this.repository);
  Future<List<Supplier>> call() => repository.getSuppliers();
}

class CreateSupplierUseCase {
  final SupplierRepository repository;
  CreateSupplierUseCase(this.repository);
  Future<void> call(Supplier supplier) => repository.createSupplier(supplier);
}

class UpdateSupplierUseCase {
  final SupplierRepository repository;
  UpdateSupplierUseCase(this.repository);
  Future<void> call(Supplier supplier) => repository.updateSupplier(supplier);
}

class DeleteSupplierUseCase {
  final SupplierRepository repository;
  DeleteSupplierUseCase(this.repository);
  Future<void> call(int id) => repository.deleteSupplier(id);
}

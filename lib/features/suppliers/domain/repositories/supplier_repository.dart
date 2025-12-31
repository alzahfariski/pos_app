import '../entities/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getSuppliers();
  Future<void> createSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(int id);
}

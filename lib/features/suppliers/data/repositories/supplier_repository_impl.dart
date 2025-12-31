import '../../domain/entities/supplier.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../data/datasources/supplier_remote_data_source.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierRemoteDataSource remoteDataSource;

  SupplierRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Supplier>> getSuppliers() async {
    final data = await remoteDataSource.getSuppliers();
    return data.map((json) => Supplier.fromJson(json)).toList();
  }

  @override
  Future<void> createSupplier(Supplier supplier) async {
    await remoteDataSource.createSupplier({
      'name': supplier.name,
      'contact': supplier.contact,
    });
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    await remoteDataSource.updateSupplier(supplier.id, {
      'name': supplier.name,
      'contact': supplier.contact,
    });
  }

  @override
  Future<void> deleteSupplier(int id) async {
    await remoteDataSource.deleteSupplier(id);
  }
}

import '../../domain/repositories/inventory_repository.dart';
import '../../data/datasources/inventory_remote_data_source.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/entities/stock_opname.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> adjustStock({
    required int productId,
    required int qtyChange,
    required String reason,
  }) async {
    await remoteDataSource.adjustStock({
      'product_id': productId,
      'qty_change': qtyChange,
      'reason': reason,
    });
  }

  @override
  Future<void> stockOpname({
    required int productId,
    required int physicalStock,
    required String note,
  }) async {
    await remoteDataSource.stockOpname({
      'product_id': productId,
      'physical_stock': physicalStock,
      'note': note,
    });
  }

  @override
  Future<List<InventoryAdjustment>> getAdjustments() async {
    final data = await remoteDataSource.getAdjustments();
    return data.map((json) => InventoryAdjustment.fromJson(json)).toList();
  }

  @override
  Future<List<StockOpname>> getStockOpnames() async {
    final data = await remoteDataSource.getStockOpnames();
    return data.map((json) => StockOpname.fromJson(json)).toList();
  }
}

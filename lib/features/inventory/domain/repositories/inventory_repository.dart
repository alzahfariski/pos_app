import '../entities/inventory_adjustment.dart';
import '../entities/stock_opname.dart';

abstract class InventoryRepository {
  Future<void> adjustStock({
    required int productId,
    required int qtyChange,
    required String reason,
  });

  Future<void> stockOpname({
    required int productId,
    required int physicalStock,
    required String note,
  });

  Future<List<InventoryAdjustment>> getAdjustments();
  Future<List<StockOpname>> getStockOpnames();
}

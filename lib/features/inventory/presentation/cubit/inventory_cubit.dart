import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/repositories/inventory_repository.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/entities/stock_opname.dart';

// States
abstract class InventoryState extends Equatable {
  const InventoryState();
  @override
  List<Object> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventorySuccess extends InventoryState {
  final String message;
  const InventorySuccess(this.message);
  @override
  List<Object> get props => [message];
}

class InventoryLoaded extends InventoryState {
  final List<InventoryAdjustment> adjustments;
  final List<StockOpname> opnames;

  const InventoryLoaded({required this.adjustments, required this.opnames});

  @override
  List<Object> get props => [adjustments, opnames];
}

class InventoryFailure extends InventoryState {
  final String message;
  const InventoryFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository repository;

  InventoryCubit({required this.repository}) : super(InventoryInitial());

  Future<void> loadData() async {
    emit(InventoryLoading());
    try {
      final adjustments = await repository.getAdjustments();
      final opnames = await repository.getStockOpnames();
      emit(InventoryLoaded(adjustments: adjustments, opnames: opnames));
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
  }

  Future<void> adjustStock({
    required int productId,
    required int qtyChange,
    required String reason,
  }) async {
    emit(InventoryLoading());
    try {
      await repository.adjustStock(
        productId: productId,
        qtyChange: qtyChange,
        reason: reason,
      );
      emit(const InventorySuccess('Stock adjusted successfully'));
      loadData(); // Refresh list
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
  }

  Future<void> stockOpname({
    required int productId,
    required int physicalStock,
    required String note,
  }) async {
    emit(InventoryLoading());
    try {
      await repository.stockOpname(
        productId: productId,
        physicalStock: physicalStock,
        note: note,
      );
      emit(const InventorySuccess('Stock opname submitted successfully'));
      loadData(); // Refresh list
    } catch (e) {
      emit(InventoryFailure(e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/usecases/purchase_usecases.dart';
import '../../domain/entities/purchase_item_input.dart';

// States
abstract class PurchaseState extends Equatable {
  const PurchaseState();
  @override
  List<Object> get props => [];
}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseLoaded extends PurchaseState {
  final List<Purchase> purchases;
  const PurchaseLoaded(this.purchases);
  @override
  List<Object> get props => [purchases];
}

class PurchaseActionSuccess extends PurchaseState {
  final String message;
  const PurchaseActionSuccess(this.message);
}

class PurchaseFailure extends PurchaseState {
  final String message;
  const PurchaseFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class PurchaseCubit extends Cubit<PurchaseState> {
  final GetPurchasesUseCase getPurchases;
  final CreatePurchaseUseCase createPurchase;

  PurchaseCubit({required this.getPurchases, required this.createPurchase})
    : super(PurchaseInitial());

  Future<void> fetchPurchases() async {
    emit(PurchaseLoading());
    try {
      final purchases = await getPurchases();
      emit(PurchaseLoaded(purchases));
    } catch (e) {
      emit(PurchaseFailure(e.toString()));
    }
  }

  Future<void> addPurchase({
    required int supplierId,
    required List<PurchaseItemInput> items,
  }) async {
    emit(PurchaseLoading());
    try {
      await createPurchase(supplierId: supplierId, items: items);
      emit(const PurchaseActionSuccess('Stock added successfully'));
      fetchPurchases();
    } catch (e) {
      emit(PurchaseFailure(e.toString()));
      fetchPurchases();
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/admin_usecases.dart';
import '../../../auth/domain/entities/user.dart';

// States
abstract class CashierState extends Equatable {
  const CashierState();
  @override
  List<Object> get props => [];
}

class CashierInitial extends CashierState {}

class CashierLoading extends CashierState {}

class CashierLoaded extends CashierState {
  final List<User> cashiers;
  const CashierLoaded(this.cashiers);
  @override
  List<Object> get props => [cashiers];
}

class CashierActionSuccess extends CashierState {
  final String message;
  const CashierActionSuccess(this.message);
}

class CashierFailure extends CashierState {
  final String message;
  const CashierFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class CashierCubit extends Cubit<CashierState> {
  final GetCashiersUseCase getCashiers;
  final CreateCashierUseCase createCashier;
  final UpdateCashierUseCase updateCashier;
  final DeleteCashierUseCase deleteCashier;

  CashierCubit({
    required this.getCashiers,
    required this.createCashier,
    required this.updateCashier,
    required this.deleteCashier,
  }) : super(CashierInitial());

  Future<void> fetchCashiers() async {
    emit(CashierLoading());
    try {
      final cashiers = await getCashiers();
      emit(CashierLoaded(cashiers));
    } catch (e) {
      emit(CashierFailure(e.toString()));
    }
  }

  Future<void> addCashier(String name, String email, String password) async {
    emit(CashierLoading());
    try {
      await createCashier(name, email, password);
      emit(const CashierActionSuccess('Cashier added successfully'));
      fetchCashiers();
    } catch (e) {
      emit(CashierFailure(e.toString()));
      fetchCashiers();
    }
  }

  Future<void> editCashier(
    int id,
    String name,
    String email, {
    String? password,
  }) async {
    emit(CashierLoading());
    try {
      await updateCashier(id, name, email, password: password);
      emit(const CashierActionSuccess('Cashier updated successfully'));
      fetchCashiers();
    } catch (e) {
      emit(CashierFailure(e.toString()));
      fetchCashiers();
    }
  }

  Future<void> removeCashier(int id) async {
    emit(CashierLoading());
    try {
      await deleteCashier(id);
      emit(const CashierActionSuccess('Cashier deleted successfully'));
      fetchCashiers();
    } catch (e) {
      emit(CashierFailure(e.toString()));
      fetchCashiers();
    }
  }
}

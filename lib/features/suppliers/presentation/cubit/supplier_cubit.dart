import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/usecases/supplier_usecases.dart';

// States
abstract class SupplierState extends Equatable {
  const SupplierState();
  @override
  List<Object> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;
  const SupplierLoaded(this.suppliers);
  @override
  List<Object> get props => [suppliers];
}

class SupplierActionSuccess extends SupplierState {
  final String message;
  const SupplierActionSuccess(this.message);
}

class SupplierFailure extends SupplierState {
  final String message;
  const SupplierFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class SupplierCubit extends Cubit<SupplierState> {
  final GetSuppliersUseCase getSuppliers;
  final CreateSupplierUseCase createSupplier;
  final UpdateSupplierUseCase updateSupplier;
  final DeleteSupplierUseCase deleteSupplier;

  SupplierCubit({
    required this.getSuppliers,
    required this.createSupplier,
    required this.updateSupplier,
    required this.deleteSupplier,
  }) : super(SupplierInitial());

  Future<void> fetchSuppliers() async {
    emit(SupplierLoading());
    try {
      final suppliers = await getSuppliers();
      emit(SupplierLoaded(suppliers));
    } catch (e) {
      emit(SupplierFailure(e.toString()));
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    emit(SupplierLoading());
    try {
      await createSupplier(supplier);
      emit(const SupplierActionSuccess('Supplier added successfully'));
      fetchSuppliers();
    } catch (e) {
      emit(SupplierFailure(e.toString()));
      fetchSuppliers();
    }
  }

  Future<void> editSupplier(Supplier supplier) async {
    emit(SupplierLoading());
    try {
      await updateSupplier(supplier);
      emit(const SupplierActionSuccess('Supplier updated successfully'));
      fetchSuppliers();
    } catch (e) {
      emit(SupplierFailure(e.toString()));
      fetchSuppliers();
    }
  }

  Future<void> removeSupplier(int id) async {
    emit(SupplierLoading());
    try {
      await deleteSupplier(id);
      emit(const SupplierActionSuccess('Supplier deleted successfully'));
      fetchSuppliers();
    } catch (e) {
      emit(SupplierFailure(e.toString()));
      fetchSuppliers();
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/process_sale.dart';
import '../../../products/domain/entities/product.dart';

// States
abstract class PosState extends Equatable {
  const PosState();
  @override
  List<Object?> get props => [];
}

class PosInitial extends PosState {}

class PosLoading extends PosState {}

class PosUpdated extends PosState {
  final List<CartItem> items;
  final int totalAmount;

  const PosUpdated({required this.items, required this.totalAmount});

  @override
  List<Object?> get props => [items, totalAmount, DateTime.now()]; // Verify updates always propagate
}

class PosSuccess extends PosState {
  final Map<String, dynamic> data; // Change, transaction info
  const PosSuccess(this.data);
  @override
  List<Object> get props => [data];
}

class PosFailure extends PosState {
  final String message;
  const PosFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class PosCubit extends Cubit<PosState> {
  final ProcessSaleUseCase processSaleUseCase;

  List<CartItem> _cartItems = [];

  PosCubit({required this.processSaleUseCase}) : super(PosInitial());

  void _emitUpdated() {
    int total = 0;
    for (var item in _cartItems) {
      total += item.totalPrice;
    }
    emit(PosUpdated(items: List.from(_cartItems), totalAmount: total));
  }

  void addToCart(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index >= 0) {
      final currentItem = _cartItems[index];
      if (currentItem.quantity < product.stock) {
        _cartItems[index] = currentItem.copyWith(
          quantity: currentItem.quantity + 1,
        );
      } else {
        // Optional: emit error or toast for max stock reached locally
      }
    } else {
      if (product.stock > 0) {
        _cartItems.add(CartItem(product: product, quantity: 1));
      }
    }
    _emitUpdated();
  }

  void removeFromCart(Product product) {
    _cartItems.removeWhere((item) => item.product.id == product.id);
    _emitUpdated();
  }

  void decreaseQuantity(Product product) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (index >= 0) {
      final currentItem = _cartItems[index];
      if (currentItem.quantity > 1) {
        _cartItems[index] = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
        );
      } else {
        _cartItems.removeAt(index);
      }
      _emitUpdated();
    }
  }

  void clearCart() {
    _cartItems = [];
    _emitUpdated();
  }

  Future<void> processSale(int paymentAmount, String paymentMethod) async {
    if (_cartItems.isEmpty) return;

    emit(PosLoading());
    try {
      final result = await processSaleUseCase(
        paymentAmount,
        _cartItems,
        paymentMethod,
      );
      emit(PosSuccess(result));
      _cartItems = []; // Clear upon success
    } catch (e) {
      _emitUpdated(); // Revert to cart view
      emit(PosFailure(e.toString()));
      emit(
        PosUpdated(
          items: List.from(_cartItems),
          totalAmount: _cartItems.fold(0, (sum, item) => sum + item.totalPrice),
        ),
      );
    }
  }

  // Helper to re-emit state for UI refresh if needed
  void refresh() => _emitUpdated();
}

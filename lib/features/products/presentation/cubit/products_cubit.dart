import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/upload_product_image.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final String searchQuery;

  const ProductsLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.searchQuery = '',
  });

  ProductsLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    String? searchQuery,
  }) {
    return ProductsLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // Alias for backward compatibility if needed, but we should switch to filteredProducts for UI
  List<Product> get products => filteredProducts;

  @override
  List<Object> get props => [allProducts, filteredProducts, searchQuery];
}

class ProductsLoadFailure extends ProductsState {
  final String message;
  const ProductsLoadFailure(this.message);
  @override
  List<Object> get props => [message];
}

class ProductOperationSuccess extends ProductsState {
  final String message;
  const ProductOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final UploadProductImageUseCase uploadProductImageUseCase;

  ProductsCubit({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.uploadProductImageUseCase,
  }) : super(ProductsInitial());

  Future<void> fetchProducts() async {
    emit(ProductsLoading());
    try {
      final products = await getProductsUseCase();

      emit(ProductsLoaded(allProducts: products, filteredProducts: products));
    } catch (e) {
      emit(ProductsLoadFailure(e.toString()));
    }
  }

  void search(String query) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final lowerQuery = query.toLowerCase();

      final filtered = currentState.allProducts.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.sku.toLowerCase().contains(lowerQuery);
      }).toList();

      emit(
        currentState.copyWith(searchQuery: query, filteredProducts: filtered),
      );
    }
  }

  Future<void> addProduct({
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
    String? imagePath,
  }) async {
    emit(ProductsLoading());
    try {
      final product = await addProductUseCase(
        name: name,
        sku: sku,
        cost: cost,
        price: price,
        stock: stock,
      );

      if (imagePath != null) {
        await uploadProductImageUseCase(product.id, imagePath);
      }

      emit(const ProductOperationSuccess("Product added successfully"));
      fetchProducts();
    } catch (e) {
      emit(ProductsLoadFailure(e.toString()));
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double cost,
    required double price,
    required int stock,
    String? imagePath,
  }) async {
    emit(ProductsLoading());
    try {
      await updateProductUseCase(
        id: id,
        name: name,
        sku: sku,
        cost: cost,
        price: price,
        stock: stock,
      );

      if (imagePath != null) {
        await uploadProductImageUseCase(id, imagePath);
      }

      emit(const ProductOperationSuccess("Product updated successfully"));
      fetchProducts();
    } catch (e) {
      emit(ProductsLoadFailure(e.toString()));
    }
  }

  Future<void> deleteProduct(int id) async {
    emit(ProductsLoading());
    try {
      await deleteProductUseCase(id);
      emit(const ProductOperationSuccess("Product deleted successfully"));
      fetchProducts();
    } catch (e) {
      emit(ProductsLoadFailure(e.toString()));
    }
  }

  Future<void> uploadImage(int id, String filePath) async {
    emit(ProductsLoading());
    try {
      await uploadProductImageUseCase(id, filePath);
      emit(const ProductOperationSuccess("Image updated successfully"));
      fetchProducts();
    } catch (e) {
      emit(ProductsLoadFailure(e.toString()));
    }
  }
}

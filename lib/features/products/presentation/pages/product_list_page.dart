import 'package:cached_network_image/cached_network_image.dart';
import 'package:pos_app/core/utils/image_helper.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/presentation/widgets/custom_dialog.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/products_cubit.dart';
import '../../domain/entities/product.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    if (product.stock > 0) {
      CustomToast.show(
        context,
        'Cannot delete product with remaining stock (${product.stock}).',
        isError: true,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Delete Product',
        content: 'Are you sure you want to delete ${product.name}?',
        primaryButtonText: 'Delete',
        onPrimaryPressed: () {
          context.read<ProductsCubit>().deleteProduct(product.id);
          Navigator.pop(context);
        },
        secondaryButtonText: 'Cancel',
        icon: Icons.warning_rounded,
        iconColor: AppColors.danger500,
      ),
    );
  }

  Future<void> _pickAndUploadImage(BuildContext context, int productId) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!context.mounted) return;
        context.read<ProductsCubit>().uploadImage(productId, image.path);
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomToast.show(context, 'Failed to pick image: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isAdmin =
        authState is AuthAuthenticated && authState.user.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FocusDetector(
        onFocusGained: () {
          context.read<ProductsCubit>().fetchProducts();
        },
        child: BlocConsumer<ProductsCubit, ProductsState>(
          listener: (context, state) {
            if (state is ProductsLoadFailure) {
              CustomToast.show(context, state.message, isError: true);
            } else if (state is ProductOperationSuccess) {
              CustomToast.show(context, state.message, isError: false);
            }
          },
          builder: (context, state) {
            if (state is ProductsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductsLoaded) {
              return Column(
                children: [
                  // Search Bar
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  context.read<ProductsCubit>().search(value),
                              decoration: InputDecoration(
                                hintText: 'Search by name or SKU...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: AppColors.neutral100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ProductsCubit>().fetchProducts();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Product List
                  Expanded(
                    child: state.filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'No products available.'
                                      : 'No products found matching "${_searchController.text}".',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth < 600) {
                                return _MobileLayout(
                                  products: state.filteredProducts,
                                  isAdmin: isAdmin,
                                  onDelete: (p) =>
                                      _showDeleteConfirmation(context, p),
                                  onEdit: (p) => context.pushNamed(
                                    AppRouteNames.productForm,
                                    extra: p,
                                  ),
                                  onUploadImage: (id) =>
                                      _pickAndUploadImage(context, id),
                                );
                              } else {
                                return _TabletLayout(
                                  products: state.filteredProducts,
                                  isAdmin: isAdmin,
                                  onDelete: (p) =>
                                      _showDeleteConfirmation(context, p),
                                  onEdit: (p) => context.pushNamed(
                                    AppRouteNames.productForm,
                                    extra: p,
                                  ),
                                  onUploadImage: (id) =>
                                      _pickAndUploadImage(context, id),
                                );
                              }
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              heroTag: 'product_fab',
              onPressed: () {
                context.pushNamed(AppRouteNames.productForm);
              },
              backgroundColor: AppColors.primary500,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text(
                'Add Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}

// --- Layouts ---

class _MobileLayout extends StatelessWidget {
  final List<Product> products;
  final bool isAdmin;
  final Function(Product) onDelete;
  final Function(Product) onEdit;
  final Function(int) onUploadImage;

  const _MobileLayout({
    required this.products,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
    required this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ProductListCard(
          product: products[index],
          isAdmin: isAdmin,
          onDelete: onDelete,
          onEdit: onEdit,
          onUploadImage: onUploadImage,
        );
      },
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final List<Product> products;
  final bool isAdmin;
  final Function(Product) onDelete;
  final Function(Product) onEdit;
  final Function(int) onUploadImage;

  const _TabletLayout({
    required this.products,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
    required this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductGridCard(
          product: products[index],
          isAdmin: isAdmin,
          onDelete: onDelete,
          onEdit: onEdit,
        );
      },
    );
  }
}

// --- Components ---

class _ProductListCard extends StatelessWidget {
  final Product product;
  final bool isAdmin;
  final Function(Product) onDelete;
  final Function(Product) onEdit;
  final Function(int) onUploadImage;

  const _ProductListCard({
    required this.product,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
    required this.onUploadImage,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isAdmin ? () => onEdit(product) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child:
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ImageHelper.sanitizeUrl(
                              product.imageUrl!,
                            ),
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: Colors.grey[100]),
                            errorWidget: (_, _, _) => Container(
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/default_product.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.sku,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            currencyFormatter.format(product.price),
                            style: const TextStyle(
                              color: AppColors.primary500,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? AppColors.success50
                                  : AppColors.danger50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.stock > 0
                                  ? '${product.stock} Stock'
                                  : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: product.stock > 0
                                    ? AppColors.success700
                                    : AppColors.danger700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  final Product product;
  final bool isAdmin;
  final Function(Product) onDelete;
  final Function(Product) onEdit;

  const _ProductGridCard({
    required this.product,
    required this.isAdmin,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child:
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ImageHelper.sanitizeUrl(
                              product.imageUrl!,
                            ),
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: Colors.grey[100]),
                            errorWidget: (_, _, _) => Container(
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/default_product.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (product.stock <= 0)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withAlpha(200),
                        alignment: Alignment.center,
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: AppColors.danger700,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  if (isAdmin)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: PopupMenuButton(
                          icon: const Icon(Icons.more_horiz, size: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: () => onEdit(product),
                            ),
                            PopupMenuItem(
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: AppColors.danger500),
                              ),
                              onTap: () => onDelete(product),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.sku,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${product.stock}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: product.stock > 0
                              ? AppColors.success600
                              : AppColors.danger600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      color: AppColors.primary500,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

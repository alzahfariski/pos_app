import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_dialog.dart';

import '../../../../core/utils/image_helper.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../cubit/pos_cubit.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PosCubit>(),
      child: const PosView(),
    );
  }
}

class PosView extends StatefulWidget {
  const PosView({super.key});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  String _searchQuery = '';
  bool _isPaymentMode = false;
  Map<String, dynamic>? _successData;

  void _togglePaymentMode() {
    setState(() {
      _isPaymentMode = !_isPaymentMode;
    });
  }

  @override
  void initState() {
    super.initState();
    final productsState = context.read<ProductsCubit>().state;
    if (productsState is! ProductsLoaded) {
      context.read<ProductsCubit>().fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        context.read<ProductsCubit>().fetchProducts();
      },
      child: BlocListener<PosCubit, PosState>(
        listener: (context, state) {
          if (state is PosFailure) {
            _showErrorDialog(context, state.message);
          } else if (state is PosSuccess) {
            _handleSuccess(context, state.data);
          } else if (state is PosUpdated) {
            // If updated (e.g. cart cleared), verify if we need to reset success mode?
            // Typically PosSuccess is an event, but state remains.
            // Wait, PosSuccess is likely emitted once.
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_successData != null) {
              return _SuccessView(
                data: _successData!,
                onNewTransaction: () {
                  setState(() {
                    _successData = null;
                    _isPaymentMode = false;
                  });
                  context
                      .read<PosCubit>()
                      .clearCart(); // Ensure cart is cleared (though backend/cubit might have done it)
                  // Also refresh products if needed
                  context.read<ProductsCubit>().fetchProducts();
                },
              );
            }

            if (constraints.maxWidth < 800) {
              return _MobileLayout(
                searchQuery: _searchQuery,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
              );
            } else {
              return _TabletLayout(
                searchQuery: _searchQuery,
                onSearchChanged: (value) =>
                    setState(() => _searchQuery = value),
                isPaymentMode: _isPaymentMode,
                onTogglePaymentMode: _togglePaymentMode,
                onSuccess: () => setState(() => _isPaymentMode = false),
              );
            }
          },
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => CustomDialog(
        title: 'Transaction Failed',
        content: message,
        primaryButtonText: 'Close',
        onPrimaryPressed: () => Navigator.pop(context),
        icon: Icons.error,
        iconColor: AppColors.danger500,
      ),
    );
  }

  void _handleSuccess(BuildContext context, Map<String, dynamic> data) {
    if (context.mounted) {
      setState(() {
        _successData = data;
      });
    }
  }
}

// --- Layouts ---

class _MobileLayout extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _MobileLayout({this.searchQuery = '', required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey),
                      onPressed: () =>
                          context.read<ProductsCubit>().fetchProducts(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _ProductGrid(crossAxisCount: 2, searchQuery: searchQuery),
          ),
        ],
      ),
      bottomNavigationBar:
          const _MobileCartBar(), // Mobile might need payment update too, but focusing on Tablet as requested for panels
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final bool isPaymentMode;
  final VoidCallback onTogglePaymentMode;
  final VoidCallback onSuccess;

  const _TabletLayout({
    this.searchQuery = '',
    required this.onSearchChanged,
    required this.isPaymentMode,
    required this.onTogglePaymentMode,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Panel
          Expanded(
            flex: 7,
            child: isPaymentMode
                ? const _OrderReviewList()
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: Colors.white,
                        child: Row(
                          children: [
                            const Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                onChanged: onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () =>
                                  context.read<ProductsCubit>().fetchProducts(),
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh Products',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _ProductGrid(
                            crossAxisCount: 4,
                            searchQuery: searchQuery,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          // Right Panel
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: isPaymentMode
                  ? _PaymentForm(onBack: onTogglePaymentMode)
                  : _CartView(onCharge: onTogglePaymentMode),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Components ---

class _ProductGrid extends StatelessWidget {
  final int crossAxisCount;
  final String searchQuery;

  const _ProductGrid({required this.crossAxisCount, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductsLoaded) {
          final filteredProducts = state.products.where((product) {
            return product.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                product.sku.toLowerCase().contains(searchQuery.toLowerCase());
          }).toList();

          if (filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.isEmpty
                        ? 'No products available.'
                        : 'No products found for "$searchQuery"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              return _ProductCard(product: filteredProducts[index]);
            },
          );
        } else if (state is ProductsLoadFailure) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final isOutOfStock = product.stock <= 0;

    return InkWell(
      onTap: isOutOfStock
          ? null
          : () {
              context.read<PosCubit>().addToCart(product);
              // Haptic feedback or toast for quick add?
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${product.name}'), duration: Duration(milliseconds: 500)));
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child:
                          product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
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
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withAlpha(179),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger500,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SOLD OUT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      color: AppColors.primary500,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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

class _MobileCartBar extends StatelessWidget {
  const _MobileCartBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        int count = 0;
        int total = 0;
        if (state is PosUpdated) {
          count = state.items.fold(0, (sum, item) => sum + item.quantity);
          total = state.totalAmount;
        }

        if (count == 0) return const SizedBox.shrink();

        final currencyFormatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<PosCubit>(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.85,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: _CartView(
                        onCharge: () {
                          Navigator.pop(context); // Close Cart Sheet
                          _showPaymentSheet(context);
                        },
                      ),
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('View Order'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      currencyFormatter.format(total),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PosCubit>(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BlocListener<PosCubit, PosState>(
            listener: (context, state) {
              if (state is PosSuccess) {
                Navigator.pop(context); // Close the sheet on success
              }
            },
            child: _PaymentForm(onBack: () => Navigator.pop(context)),
          ),
        ),
      ),
    );
  }
}

class _CartView extends StatelessWidget {
  final VoidCallback? onCharge;
  const _CartView({this.onCharge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Order',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => context.read<PosCubit>().clearCart(),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger500,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<PosCubit, PosState>(
            builder: (context, state) {
              List items = [];
              if (state is PosUpdated) items = state.items;

              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    children: [
                      // Ideally show small thumb image here
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          image: item.product.imageUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    ImageHelper.sanitizeUrl(
                                      item.product.imageUrl!,
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: AssetImage(
                                    'assets/images/default_product.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        child: item.product.imageUrl == null
                            ? const Icon(Icons.image, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                            Text(
                              currencyFormatter.format(item.product.price),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _CircleButton(
                            icon: Icons.remove,
                            onTap: () => context
                                .read<PosCubit>()
                                .decreaseQuantity(item.product),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _CircleButton(
                            icon: Icons.add,
                            onTap: () => context.read<PosCubit>().addToCart(
                              item.product,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        // Footer
        BlocBuilder<PosCubit, PosState>(
          builder: (context, state) {
            int total = 0;
            if (state is PosUpdated) total = state.totalAmount;
            final currencyFormatter = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 16)),
                      Text(
                        currencyFormatter.format(total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: total > 0 && onCharge != null
                          ? onCharge
                          : null,
                      child: const Text(
                        'CHARGE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}

class _PaymentForm extends StatefulWidget {
  final VoidCallback onBack;
  const _PaymentForm({required this.onBack});

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  String _selectedMethod = 'CASH';
  final TextEditingController _amountController = TextEditingController();

  final List<String> _paymentMethods = [
    'CASH',
    'DEBIT_CARD',
    'CREDIT_CARD',
    'QRIS',
    'BANK_TRANSFER',
  ];

  final List<int> _quickAmounts = [50000, 100000, 150000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        int total = 0;
        if (state is PosUpdated) {
          total = state.totalAmount;
        }

        // Calculate change
        int inputAmount =
            int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
        int change = inputAmount - total;
        bool isValid = inputAmount >= total;

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Payment Method
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _paymentMethods.map((method) {
                      final isSelected = _selectedMethod == method;
                      return ChoiceChip(
                        label: Text(method.replaceAll('_', ' ')),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedMethod = method;
                              if (_selectedMethod != 'CASH') {
                                final state = context.read<PosCubit>().state;
                                if (state is PosUpdated) {
                                  _amountController.text = state.totalAmount
                                      .toString();
                                }
                              } else {
                                _amountController.clear();
                              }
                            });
                          }
                        },
                        checkmarkColor: Colors.white,
                        selectedColor: AppColors.primary500,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Total Amount Display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary500),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total to Pay',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary500,
                          ),
                        ),
                        Text(
                          _formatCurrency(total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Amount
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    readOnly: _selectedMethod != 'CASH',
                    decoration: InputDecoration(
                      labelText: 'Amount Paid',
                      border: const OutlineInputBorder(),
                      prefixText: 'Rp ',
                      filled: _selectedMethod != 'CASH',
                      fillColor: _selectedMethod != 'CASH'
                          ? Colors.grey[200]
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  // Quick Buttons (Only for Cash)
                  if (_selectedMethod == 'CASH') ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('Uang Pas'),
                          onPressed: () {
                            _amountController.text = total.toString();
                            setState(() {});
                          },
                        ),
                        ..._quickAmounts.map(
                          (amount) => ActionChip(
                            label: Text(_formatCurrency(amount)),
                            onPressed: () {
                              _amountController.text = amount.toString();
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Change
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change (Kembalian)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatCurrency(change < 0 ? 0 : change),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: change < 0
                                ? AppColors.danger500
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer Action
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValid && total > 0
                      ? () {
                          context.read<PosCubit>().processSale(
                            inputAmount,
                            _selectedMethod,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SUBMIT PAYMENT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OrderReviewList extends StatelessWidget {
  const _OrderReviewList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          width: double.infinity,
          child: const Text(
            'Order Review',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: BlocBuilder<PosCubit, PosState>(
            builder: (context, state) {
              List items = [];
              if (state is PosUpdated) items = state.items;

              if (items.isEmpty) return const SizedBox.shrink();

              final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        image: item.product.imageUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                  ImageHelper.sanitizeUrl(
                                    item.product.imageUrl!,
                                  ),
                                ),
                                fit: BoxFit.cover,
                              )
                            : DecorationImage(
                                image: AssetImage(
                                  'assets/images/default_product.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: item.product.imageUrl == null
                          ? const Icon(Icons.image, color: Colors.grey)
                          : null,
                    ),
                    title: Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.quantity} x ${currencyFormatter.format(item.product.price)}',
                    ),
                    trailing: Text(
                      currencyFormatter.format(item.totalPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onNewTransaction;

  const _SuccessView({required this.data, required this.onNewTransaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final invoiceNumber = data['invoice_number'] ?? '-';
    // Handle created_at formatting safely
    final createdStr = data['created_at'];
    String createdDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (createdStr != null) {
      try {
        createdDate = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.parse(createdStr));
      } catch (_) {}
    }

    final cashierName = data['cashier'] != null
        ? (data['cashier']['name'] ?? '-')
        : (data['cashier_id']?.toString() ?? '-');

    final int total = data['total_amount'] is int
        ? data['total_amount']
        : (int.tryParse(data['total_amount'].toString()) ?? 0);
    final int paid = data['payment_amount'] is int
        ? data['payment_amount']
        : (int.tryParse(data['payment_amount'].toString()) ?? 0);
    final int change = data['change_amount'] is int
        ? data['change_amount']
        : (int.tryParse(data['change_amount'].toString()) ?? 0);
    final paymentMethod = data['payment_method'] ?? 'CASH';

    final items = (data['items'] as List?) ?? [];

    // Assuming we want a split layout regardless of device, or maybe stacked on mobile
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;

        Widget leftPanel = Container(
          color: AppColors.primary500,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.primary500,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Transaction Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'No. Invoice',
                style: TextStyle(
                  color: Colors.white.withAlpha(179),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                invoiceNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26), // Translucent white
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          currencyFormatter.format(total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Change',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          currencyFormatter.format(change),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          // CustomToast.show(context, 'Printing Receipt...'),
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Printing Receipt...'),
                            ),
                          ),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Receipt'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onNewTransaction,
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: const Text('New Transaction'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary500,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );

        Widget rightPanel = Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Receipt Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Info Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'No. Invoice',
                      value: invoiceNumber,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Date',
                      value: createdDate,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Cashier',
                      value: cashierName,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Purchase Details
              const Text(
                'Purchase Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      // Parsing based on GET /api/pos/{id} response structure
                      final productName = item['product'] != null
                          ? (item['product']['name'] ?? '-')
                          : (item['product_name'] ?? '-');

                      final qty = item['qty'] ?? item['quantity'] ?? 0;
                      final price =
                          item['price_snapshot'] ?? item['price'] ?? 0;
                      final subtotal =
                          item['subtotal'] ??
                          item['total_price'] ??
                          (qty * price);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$qty x ${currencyFormatter.format(price)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currencyFormatter.format(subtotal),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Totals
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Subtotal',
                      value: currencyFormatter.format(total),
                      isBold: true,
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Payment ($paymentMethod)',
                      value: currencyFormatter.format(paid),
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Change',
                      value: currencyFormatter.format(change),
                      color: AppColors.success500,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                Expanded(flex: 5, child: leftPanel),
                Expanded(flex: 5, child: rightPanel),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 600,
                    width: double.infinity,
                    child: leftPanel,
                  ), // Fixed height for impact
                  SizedBox(
                    height: 800,
                    width: double.infinity,
                    child: rightPanel,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

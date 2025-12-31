import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../../../core/presentation/widgets/date_filter_bar.dart';
import '../../domain/entities/purchase.dart';
import '../cubit/purchase_cubit.dart';
import 'purchase_form_page.dart';

class PurchaseListPage extends StatelessWidget {
  const PurchaseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PurchaseCubit>()..fetchPurchases(),
      child: const _PurchaseListView(),
    );
  }
}

class _PurchaseListView extends StatefulWidget {
  const _PurchaseListView();

  @override
  State<_PurchaseListView> createState() => _PurchaseListViewState();
}

// ... imports

// ...

class _PurchaseListViewState extends State<_PurchaseListView> {
  Purchase? _selectedPurchase;

  // Filtering Logic
  DateFilterType _filterType = DateFilterType.all;
  DateTimeRange? _filterRange;

  void _onFilterChanged(DateFilterType type, DateTimeRange? range) {
    setState(() {
      _filterType = type;
      _filterRange = range;
    });
  }

  List<Purchase> _filterPurchases(List<Purchase> allPurchases) {
    if (_filterType == DateFilterType.all) return allPurchases;
    if (_filterRange == null) return allPurchases;

    return allPurchases.where((purchase) {
      final date = DateTime.parse(purchase.date);
      return date.isAfter(_filterRange!.start) &&
          date.isBefore(_filterRange!.end);
    }).toList();
  }

  void _openForm(BuildContext context) async {
    // ... existing _openForm logic
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PurchaseCubit>(),
          child: const PurchaseFormPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<PurchaseCubit, PurchaseState>(
        listener: (context, state) {
          if (state is PurchaseFailure) {
            CustomToast.show(context, state.message, isError: true);
          } else if (state is PurchaseActionSuccess) {
            CustomToast.show(context, state.message, isError: false);
          }
        },
        builder: (context, state) {
          if (state is PurchaseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PurchaseLoaded) {
            final filteredPurchases = _filterPurchases(state.purchases);

            return Column(
              children: [
                DateFilterBar(
                  selectedType: _filterType,
                  customRange: _filterRange,
                  onFilterChanged: _onFilterChanged,
                ),
                Expanded(
                  child: filteredPurchases.isEmpty
                      ? const Center(child: Text('No purchase history found.'))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 800) {
                              return _MobileLayout(
                                purchases: filteredPurchases,
                                onTap: (p) =>
                                    _showPurchaseDetailSheet(context, p),
                              );
                            } else {
                              return _TabletLayout(
                                purchases: filteredPurchases,
                                selectedPurchase: _selectedPurchase,
                                onSelect: (p) =>
                                    setState(() => _selectedPurchase = p),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'purchase_fab',
        backgroundColor: AppColors.primary500,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Stock In', style: TextStyle(color: Colors.white)),
        onPressed: () => _openForm(context),
      ),
    );
  }

  void _showPurchaseDetailSheet(BuildContext context, Purchase purchase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _PurchaseDetail(purchase: purchase),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Layouts ---

class _MobileLayout extends StatelessWidget {
  final List<Purchase> purchases;
  final Function(Purchase) onTap;

  const _MobileLayout({required this.purchases, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: purchases.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _PurchaseListCard(
          purchase: purchases[index],
          isSelected: false,
          onTap: () => onTap(purchases[index]),
        );
      },
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final List<Purchase> purchases;
  final Purchase? selectedPurchase;
  final Function(Purchase) onSelect;

  const _TabletLayout({
    required this.purchases,
    required this.selectedPurchase,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // List Right
        Expanded(
          flex: 4,
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: purchases.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = purchases[index];
              return _PurchaseListCard(
                purchase: p,
                isSelected: selectedPurchase?.id == p.id,
                onTap: () => onSelect(p),
              );
            },
          ),
        ),
        // Detail Left
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: selectedPurchase == null
                ? const Center(child: Text('Select a purchase to view details'))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _PurchaseDetail(purchase: selectedPurchase!),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// --- Components ---

class _PurchaseListCard extends StatelessWidget {
  final Purchase purchase;
  final bool isSelected;
  final VoidCallback onTap;

  const _PurchaseListCard({
    required this.purchase,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateStr = DateFormat(
      'dd MMM yyyy, HH:mm',
    ).format(DateTime.parse(purchase.date));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary500, width: 2)
              : null,
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  purchase.supplierName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  currencyFormatter.format(purchase.totalCost),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '• $dateStr',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseDetail extends StatelessWidget {
  final Purchase purchase;

  const _PurchaseDetail({required this.purchase});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateStr = DateFormat(
      'dd MMMM yyyy, HH:mm',
    ).format(DateTime.parse(purchase.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inventory, color: AppColors.primary500),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock In',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(dateStr, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Supplier Info
        const Text(
          'Supplier',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          purchase.supplierName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // Items
        const Text(
          'Items',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...purchase.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${item.quantity} Qty @ ${currencyFormatter.format(item.cost)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormatter.format(item.cost * item.quantity),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Cost', style: TextStyle(fontSize: 16)),
            Text(
              currencyFormatter.format(purchase.totalCost),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

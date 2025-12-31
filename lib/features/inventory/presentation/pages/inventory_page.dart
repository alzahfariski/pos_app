import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/searchable_selection_field.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/domain/entities/product.dart';
import '../cubit/inventory_cubit.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/entities/stock_opname.dart';
import '../../../../core/presentation/widgets/date_filter_bar.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<InventoryCubit>()..loadData()),
        BlocProvider(create: (context) => sl<ProductsCubit>()..fetchProducts()),
      ],
      child: const _InventoryView(),
    );
  }
}

// ... imports

// ...

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  // Filtering Logic
  DateFilterType _filterType = DateFilterType.all;
  DateTimeRange? _filterRange;

  void _onFilterChanged(DateFilterType type, DateTimeRange? range) {
    setState(() {
      _filterType = type;
      _filterRange = range;
    });
  }

  bool _isDateInRange(String dateStr) {
    if (_filterType == DateFilterType.all) return true;
    if (_filterRange == null) return true;

    final date = DateTime.parse(dateStr);
    return date.isAfter(_filterRange!.start) &&
        date.isBefore(_filterRange!.end);
  }

  void _showAdjustmentForm(BuildContext context) {
    // ... same implementation as before ...
    // Need to maintain contexts correctly or just implementation from original
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<InventoryCubit>()),
            BlocProvider.value(value: context.read<ProductsCubit>()),
          ],
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const _AdjustmentForm(),
          ),
        );
      },
    );
  }

  void _showOpnameForm(BuildContext context) {
    // ... same implementation as before ...
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<InventoryCubit>()),
            BlocProvider.value(value: context.read<ProductsCubit>()),
          ],
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const _OpnameForm(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryFailure) {
            CustomToast.show(context, state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            final filteredAdjustments = state.adjustments
                .where((a) => _isDateInRange(a.createdAt))
                .toList();
            final filteredOpnames = state.opnames
                .where((o) => _isDateInRange(o.createdAt))
                .toList();

            return Column(
              children: [
                DateFilterBar(
                  selectedType: _filterType,
                  customRange: _filterRange,
                  onFilterChanged: _onFilterChanged,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Tablet Layout: Split View (Adjustments Left, Opnames Right)
                      if (constraints.maxWidth >= 800) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _SectionContainer(
                                  title: 'Adjustments',
                                  icon: Icons.tune,
                                  actionLabel: 'New Adjustment',
                                  onAction: () => _showAdjustmentForm(context),
                                  child: _AdjustmentList(
                                    adjustments: filteredAdjustments,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _SectionContainer(
                                  title: 'Stock Opnames',
                                  icon: Icons.checklist,
                                  actionLabel: 'New Audit',
                                  onAction: () => _showOpnameForm(context),
                                  child: _OpnameList(opnames: filteredOpnames),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      // Mobile Layout: Tabs
                      else {
                        return DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.white,
                                child: const TabBar(
                                  labelColor: AppColors.primary500,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: AppColors.primary500,
                                  indicatorWeight: 3,
                                  tabs: [
                                    Tab(text: 'Adjustments'),
                                    Tab(text: 'Stock Opname'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    Stack(
                                      children: [
                                        _AdjustmentList(
                                          adjustments: filteredAdjustments,
                                          padding: const EdgeInsets.all(16),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          right: 16,
                                          child: FloatingActionButton.extended(
                                            heroTag: 'adj_fab',
                                            onPressed: () =>
                                                _showAdjustmentForm(context),
                                            backgroundColor:
                                                AppColors.primary500,
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              'Adjust',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      children: [
                                        _OpnameList(
                                          opnames: filteredOpnames,
                                          padding: const EdgeInsets.all(16),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          right: 16,
                                          child: FloatingActionButton.extended(
                                            heroTag: 'opname_fab',
                                            onPressed: () =>
                                                _showOpnameForm(context),
                                            backgroundColor: Colors.orange,
                                            icon: const Icon(
                                              Icons.playlist_add_check,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              'Audit',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
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
    );
  }
}

// --- Components ---

class _SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;
  final Widget child;

  const _SectionContainer({
    required this.title,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primary500),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary50,
                    foregroundColor: AppColors.primary600,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(actionLabel),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AdjustmentList extends StatelessWidget {
  final List<InventoryAdjustment> adjustments;
  final EdgeInsetsGeometry padding;

  const _AdjustmentList({
    required this.adjustments,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (adjustments.isEmpty) {
      return const Center(child: Text('No history found.'));
    }

    return ListView.separated(
      padding: padding,
      itemCount: adjustments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = adjustments[index];
        final isNegative = item.qtyChange < 0;
        final dateStr = DateFormat(
          'dd MMM, HH:mm',
        ).format(DateTime.parse(item.createdAt));

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isNegative
                  ? AppColors.danger50
                  : AppColors.success50,
              child: Icon(
                isNegative ? Icons.remove : Icons.add,
                color: isNegative ? AppColors.danger500 : AppColors.success500,
              ),
            ),
            title: Text(
              item.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${item.reason} • $dateStr',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text(
              '${item.qtyChange > 0 ? '+' : ''}${item.qtyChange}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isNegative ? AppColors.danger500 : AppColors.success500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OpnameList extends StatelessWidget {
  final List<StockOpname> opnames;
  final EdgeInsetsGeometry padding;

  const _OpnameList({required this.opnames, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    if (opnames.isEmpty) {
      return const Center(child: Text('No audit history found.'));
    }

    return ListView.separated(
      padding: padding,
      itemCount: opnames.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = opnames[index];
        final diff = item.difference;
        final isNegative = diff < 0;
        final isZero = diff == 0;
        final dateStr = DateFormat(
          'dd MMM, HH:mm',
        ).format(DateTime.parse(item.createdAt));

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isZero
                  ? Colors.grey[100]
                  : (isNegative ? AppColors.danger50 : AppColors.success50),
              child: Icon(
                isZero
                    ? Icons.check
                    : (isNegative ? Icons.trending_down : Icons.trending_up),
                color: isZero
                    ? Colors.grey
                    : (isNegative ? AppColors.danger500 : AppColors.success500),
              ),
            ),
            title: Text(
              item.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Sys: ${item.systemStock} → Real: ${item.physicalStock} • $dateStr',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Text(
              '${diff > 0 ? '+' : ''}$diff',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isZero
                    ? Colors.black54
                    : (isNegative ? AppColors.danger500 : AppColors.success500),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Forms (Same logic, slightly nicer UI) ---

class _AdjustmentForm extends StatefulWidget {
  const _AdjustmentForm();

  @override
  State<_AdjustmentForm> createState() => _AdjustmentFormState();
}

class _AdjustmentFormState extends State<_AdjustmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _reasonController = TextEditingController();
  Product? _selectedProduct;

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
      final qty = int.tryParse(_qtyController.text) ?? 0;
      context.read<InventoryCubit>().adjustStock(
        productId: _selectedProduct!.id,
        qtyChange: qty,
        reason: _reasonController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryCubit, InventoryState>(
      listener: (context, state) {
        if (state is InventorySuccess) {
          CustomToast.show(context, state.message);
          Navigator.pop(context);
        } else if (state is InventoryFailure) {
          CustomToast.show(context, state.message, isError: true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Stock Adjustment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoaded) {
                    return SearchableSelectionField<Product>(
                      label: 'Select Product',
                      value: _selectedProduct,
                      items: state.products,
                      labelBuilder: (p) => '${p.name} (${p.stock})',
                      onChanged: (val) =>
                          setState(() => _selectedProduct = val),
                      validator: (v) => v == null ? 'Required' : null,
                    );
                  }
                  return const LinearProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Qty Change',
                        hintText: '-5 or 10',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'e.g. Broken',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Adjustment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpnameForm extends StatefulWidget {
  const _OpnameForm();

  @override
  State<_OpnameForm> createState() => _OpnameFormState();
}

class _OpnameFormState extends State<_OpnameForm> {
  final _formKey = GlobalKey<FormState>();
  final _stockController = TextEditingController();
  final _noteController = TextEditingController();
  Product? _selectedProduct;

  @override
  void dispose() {
    _stockController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
      final stock = int.tryParse(_stockController.text) ?? 0;
      context.read<InventoryCubit>().stockOpname(
        productId: _selectedProduct!.id,
        physicalStock: stock,
        note: _noteController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryCubit, InventoryState>(
      listener: (context, state) {
        if (state is InventorySuccess) {
          CustomToast.show(context, state.message);
          Navigator.pop(context);
        } else if (state is InventoryFailure) {
          CustomToast.show(context, state.message, isError: true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Stock Opname (Audit)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoaded) {
                    return SearchableSelectionField<Product>(
                      label: 'Select Product',
                      value: _selectedProduct,
                      items: state.products,
                      labelBuilder: (p) => '${p.name} (Sys: ${p.stock})',
                      onChanged: (val) =>
                          setState(() => _selectedProduct = val),
                      validator: (v) => v == null ? 'Required' : null,
                    );
                  }
                  return const LinearProgressIndicator();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Physical Stock (Real)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Monthly Audit',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Audit Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

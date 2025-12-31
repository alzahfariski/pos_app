import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/searchable_selection_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../suppliers/presentation/cubit/supplier_cubit.dart';
import '../../../products/domain/entities/product.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../domain/entities/purchase_item_input.dart';
import '../cubit/purchase_cubit.dart';

class PurchaseFormPage extends StatelessWidget {
  const PurchaseFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<ProductsCubit>()..fetchProducts()),
        BlocProvider(
          create: (context) => sl<SupplierCubit>()..fetchSuppliers(),
        ),
      ],
      child: const PurchaseFormView(),
    );
  }
}

class PurchaseFormView extends StatefulWidget {
  const PurchaseFormView({super.key});

  @override
  State<PurchaseFormView> createState() => _PurchaseFormViewState();
}

class _PurchaseFormViewState extends State<PurchaseFormView> {
  final _formKey = GlobalKey<FormState>();
  Supplier? _selectedSupplier;
  final List<_ItemInput> _items = [];

  void _addItem() {
    setState(() {
      _items.add(_ItemInput());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _save(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedSupplier == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a supplier')),
        );
        return;
      }
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')),
        );
        return;
      }

      final purchaseItems = _items.map((item) {
        return PurchaseItemInput(
          productId: item.product!.id,
          quantity: int.parse(item.qtyController.text),
        );
      }).toList();

      context.read<PurchaseCubit>().addPurchase(
        supplierId: _selectedSupplier!.id,
        items: purchaseItems,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context);
        } else if (state is PurchaseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'New Stock In',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.grey[50],
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSupplierSection(),
                const SizedBox(height: 24),
                _buildItemsSection(),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => _save(context),
                  child: const Text(
                    'Submit Purchase',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supplier Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<SupplierCubit, SupplierState>(
              builder: (context, state) {
                if (state is SupplierLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SupplierLoaded) {
                  return SearchableSelectionField<Supplier>(
                    label: 'Select Supplier',
                    value: _selectedSupplier,
                    items: state.suppliers,
                    labelBuilder: (supplier) => supplier.name,
                    onChanged: (val) => setState(() => _selectedSupplier = val),
                    validator: (v) => v == null ? 'Required' : null,
                  );
                }
                return const Text('Failed to load suppliers');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Stock Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Item'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary500,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No items added yet',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (ctrl, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildItemRow(index);
            },
          ),
      ],
    );
  }

  Widget _buildItemRow(int index) {
    final item = _items[index];
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, state) {
                      if (state is ProductsLoaded) {
                        // Get IDs selected in OTHER rows
                        final selectedProductIds = _items
                            .where((i) => i != item && i.product != null)
                            .map((i) => i.product!.id)
                            .toSet();

                        // Filter products: Include if NOT in selectedProductIds
                        final availableProducts = state.products
                            .where((p) => !selectedProductIds.contains(p.id))
                            .toList();

                        return SearchableSelectionField<Product>(
                          label: 'Product',
                          value: item.product,
                          items: availableProducts,
                          labelBuilder: (product) => product.name,
                          onChanged: (val) {
                            setState(() {
                              item.product = val;
                              item.costController.text = val.cost
                                  .toInt()
                                  .toString();
                            });
                          },
                          validator: (v) => v == null ? 'Required' : null,
                        );
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.costController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Cost (per Qty)',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: item.qtyController,
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty || int.tryParse(v) == null)
                        ? 'Invalid'
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemInput {
  Product? product;
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController costController = TextEditingController();
}

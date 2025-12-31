import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_dialog.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../domain/entities/supplier.dart';
import '../cubit/supplier_cubit.dart';

class SupplierListPage extends StatelessWidget {
  const SupplierListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SupplierCubit>()..fetchSuppliers(),
      child: const SupplierListView(),
    );
  }
}

class SupplierListView extends StatelessWidget {
  const SupplierListView({super.key});

  void _showDeleteConfirmation(BuildContext context, Supplier supplier) {
    // Capture the cubit from the current context correctly
    final supplierCubit = context.read<SupplierCubit>();

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Delete Supplier',
        content: 'Are you sure you want to delete ${supplier.name}?',
        primaryButtonText: 'Delete',
        onPrimaryPressed: () {
          // Use the captured cubit
          supplierCubit.removeSupplier(supplier.id);
          Navigator.pop(context);
        },
        secondaryButtonText: 'Cancel',
        icon: Icons.warning_rounded,
        iconColor: AppColors.danger500,
      ),
    );
  }

  void _openForm(BuildContext context, {Supplier? supplier}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SupplierCubit>(),
        child: _SupplierFormModal(supplier: supplier),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<SupplierCubit, SupplierState>(
        listener: (context, state) {
          if (state is SupplierFailure) {
            CustomToast.show(context, state.message, isError: true);
          } else if (state is SupplierActionSuccess) {
            CustomToast.show(context, state.message, isError: false);
          }
        },
        builder: (context, state) {
          if (state is SupplierLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SupplierLoaded) {
            if (state.suppliers.isEmpty) {
              return const Center(child: Text('No suppliers found.'));
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return _MobileLayout(
                    suppliers: state.suppliers,
                    onEdit: (s) => _openForm(context, supplier: s),
                    onDelete: (s) => _showDeleteConfirmation(context, s),
                  );
                } else {
                  return _TabletLayout(
                    suppliers: state.suppliers,
                    onEdit: (s) => _openForm(context, supplier: s),
                    onDelete: (s) => _showDeleteConfirmation(context, s),
                  );
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'supplier_fab',
        backgroundColor: AppColors.primary500,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Supplier',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _openForm(context),
      ),
    );
  }
}

// --- Layouts ---

class _MobileLayout extends StatelessWidget {
  final List<Supplier> suppliers;
  final Function(Supplier) onEdit;
  final Function(Supplier) onDelete;

  const _MobileLayout({
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: suppliers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _SupplierCard(
          supplier: suppliers[index],
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final List<Supplier> suppliers;
  final Function(Supplier) onEdit;
  final Function(Supplier) onDelete;

  const _TabletLayout({
    required this.suppliers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 3.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        return _SupplierCard(
          supplier: suppliers[index],
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

// --- Components ---

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final Function(Supplier) onEdit;
  final Function(Supplier) onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary50,
          child: Text(
            supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
            style: const TextStyle(
              color: AppColors.primary700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: supplier.contact != null && supplier.contact!.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      supplier.contact!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              )
            : null,
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => onEdit(supplier),
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 20, color: AppColors.warning500),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => onDelete(supplier),
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.danger500),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: AppColors.danger500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierFormModal extends StatefulWidget {
  final Supplier? supplier;

  const _SupplierFormModal({this.supplier});

  @override
  State<_SupplierFormModal> createState() => _SupplierFormModalState();
}

class _SupplierFormModalState extends State<_SupplierFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _contactController = TextEditingController(
      text: widget.supplier?.contact ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        id: widget.supplier?.id ?? 0,
        name: _nameController.text,
        contact: _contactController.text,
      );

      if (widget.supplier == null) {
        context.read<SupplierCubit>().addSupplier(supplier);
      } else {
        context.read<SupplierCubit>().editSupplier(supplier);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEdit ? 'Edit Supplier' : 'Add New Supplier',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Supplier Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'Contact (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _save,
              child: Text(
                isEdit ? 'Update Supplier' : 'Create Supplier',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

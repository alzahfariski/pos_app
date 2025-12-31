import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_dialog.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/cashier_cubit.dart';

class CashierListPage extends StatelessWidget {
  const CashierListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CashierCubit>()..fetchCashiers(),
      child: const _CashierListView(),
    );
  }
}

class _CashierListView extends StatelessWidget {
  const _CashierListView();

  void _showDeleteConfirmation(BuildContext context, User user) {
    final cashierCubit = context.read<CashierCubit>();

    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Delete Cashier',
        content: 'Are you sure you want to delete ${user.name}?',
        primaryButtonText: 'Delete',
        onPrimaryPressed: () {
          cashierCubit.removeCashier(user.id);
          Navigator.pop(context);
        },
        secondaryButtonText: 'Cancel',
        icon: Icons.warning_rounded,
        iconColor: AppColors.danger500,
      ),
    );
  }

  void _openForm(BuildContext context, {User? user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CashierCubit>(),
        child: _CashierFormModal(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<CashierCubit, CashierState>(
        listener: (context, state) {
          if (state is CashierFailure) {
            CustomToast.show(context, state.message, isError: true);
          } else if (state is CashierActionSuccess) {
            CustomToast.show(context, state.message, isError: false);
          }
        },
        builder: (context, state) {
          if (state is CashierLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CashierLoaded) {
            if (state.cashiers.isEmpty) {
              return const Center(child: Text('No cashiers found.'));
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return _MobileLayout(
                    users: state.cashiers,
                    onEdit: (u) => _openForm(context, user: u),
                    onDelete: (u) => _showDeleteConfirmation(context, u),
                  );
                } else {
                  return _TabletLayout(
                    users: state.cashiers,
                    onEdit: (u) => _openForm(context, user: u),
                    onDelete: (u) => _showDeleteConfirmation(context, u),
                  );
                }
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cashier_fab',
        backgroundColor: AppColors.primary500,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Cashier', style: TextStyle(color: Colors.white)),
        onPressed: () => _openForm(context),
      ),
    );
  }
}

// --- Layouts ---

class _MobileLayout extends StatelessWidget {
  final List<User> users;
  final Function(User) onEdit;
  final Function(User) onDelete;

  const _MobileLayout({
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _CashierCard(
          user: users[index],
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final List<User> users;
  final Function(User) onEdit;
  final Function(User) onDelete;

  const _TabletLayout({
    required this.users,
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
      itemCount: users.length,
      itemBuilder: (context, index) {
        return _CashierCard(
          user: users[index],
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

// --- Components ---

class _CashierCard extends StatelessWidget {
  final User user;
  final Function(User) onEdit;
  final Function(User) onDelete;

  const _CashierCard({
    required this.user,
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
            user.name!.isNotEmpty ? user.name![0].toUpperCase() : 'C',
            style: const TextStyle(
              color: AppColors.primary700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name ?? 'No Name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          user.email!,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () => onEdit(user),
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 20, color: AppColors.warning500),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => onDelete(user),
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

class _CashierFormModal extends StatefulWidget {
  final User? user;

  const _CashierFormModal({this.user});

  @override
  State<_CashierFormModal> createState() => _CashierFormModalState();
}

class _CashierFormModalState extends State<_CashierFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (widget.user == null) {
        // Add
        if (_passwordController.text.isEmpty) {
          CustomToast.show(
            context,
            'Password is required for new cashier',
            isError: true,
          );
          return;
        }
        context.read<CashierCubit>().addCashier(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      } else {
        // Edit
        context.read<CashierCubit>().editCashier(
          widget.user!.id,
          _nameController.text,
          _emailController.text,
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
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
                  isEdit ? 'Edit Cashier' : 'Add New Cashier',
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
                labelText: 'Name',
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
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Email is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: isEdit ? 'New Password (Optional)' : 'Password',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                helperText: isEdit
                    ? 'Leave empty to keep current password'
                    : null,
              ),
              obscureText: true,
              validator: (v) {
                if (!isEdit && (v == null || v.isEmpty)) {
                  return 'Password is required';
                }
                if (v != null && v.isNotEmpty && v.length < 6) {
                  return 'Password must be at least 6 chars';
                }
                return null;
              },
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
                isEdit ? 'Update Cashier' : 'Create Cashier',
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

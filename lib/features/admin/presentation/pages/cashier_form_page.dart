import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/cashier_cubit.dart';

class CashierFormPage extends StatefulWidget {
  final User? user;

  const CashierFormPage({super.key, this.user});

  @override
  State<CashierFormPage> createState() => _CashierFormPageState();
}

class _CashierFormPageState extends State<CashierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController =
        TextEditingController(); // Empty for edit unless changing
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Cashier' : 'Add New Cashier'),
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: isEdit ? 'New Password (Optional)' : 'Password',
                  border: const OutlineInputBorder(),
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _save,
                  child: Text(isEdit ? 'Update Cashier' : 'Create Cashier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

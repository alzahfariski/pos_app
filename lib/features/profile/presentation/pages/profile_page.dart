import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../../../core/presentation/widgets/custom_dialog.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.goNamed(AppRouteNames.login);
        } else if (state is AuthProfileUpdated) {
          CustomToast.show(context, 'Profile updated successfully.');
        } else if (state is AuthPasswordUpdated) {
          CustomToast.show(context, 'Password updated successfully.');
        } else if (state is AuthFailure) {
          CustomToast.show(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Tablet/Desktop: Centered Container
                  if (constraints.maxWidth > 800) {
                    return Center(
                      child: Container(
                        width: 600,
                        margin: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 20),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _ProfileHeader(user: state.user, isTablet: true),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _ProfileSettings(user: state.user),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  // Mobile: Full width
                  return Column(
                    children: [
                      _ProfileHeader(user: state.user, isTablet: false),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _ProfileSettings(user: state.user),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user; // Using dynamic or AuthUser type
  final bool isTablet;

  const _ProfileHeader({required this.user, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: isTablet
            ? const BorderRadius.vertical(top: Radius.circular(24))
            : const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.primary200,
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: isTablet ? 48 : MediaQuery.of(context).padding.top + 24,
        bottom: 48,
        left: 24,
        right: 24,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                user.name?[0].toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  color: AppColors.primary600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name ?? 'Guest User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.email ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role?.toUpperCase() ?? 'USER',
              style: const TextStyle(
                color: AppColors.primary500,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettings extends StatelessWidget {
  final dynamic user;

  const _ProfileSettings({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Account Settings'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: const ContainerIcon(
                  icon: Icons.person,
                  color: AppColors.primary500,
                ),
                title: const Text('Edit Profile'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthCubit>(),
                      child: _UpdateProfileDialog(user: user),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1),
              ),
              ListTile(
                leading: const ContainerIcon(
                  icon: Icons.lock,
                  color: AppColors.warning500,
                ),
                title: const Text('Change Password'),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<AuthCubit>(),
                      child: const _ChangePasswordDialog(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger50,
              foregroundColor: AppColors.danger500,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class ContainerIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const ContainerIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _UpdateProfileDialog extends StatefulWidget {
  final dynamic user;
  const _UpdateProfileDialog({required this.user});

  @override
  State<_UpdateProfileDialog> createState() => _UpdateProfileDialogState();
}

class _UpdateProfileDialogState extends State<_UpdateProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Update Profile',
      content: '',
      icon: Icons.person_outline,
      iconColor: AppColors.primary500,
      contentWidget: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty || !v.contains('@')
                  ? 'Valid email is required'
                  : null,
            ),
          ],
        ),
      ),
      primaryButtonText: 'Update',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<AuthCubit>().updateProfile(
            name: _nameController.text,
            email: _emailController.text,
          );
          Navigator.pop(context);
        }
      },
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Change Password',
      content: '',
      icon: Icons.lock_outline,
      iconColor: AppColors.warning500,
      contentWidget: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPasswordField(
              controller: _currentController,
              label: 'Current Password',
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newController,
              label: 'New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (v) =>
                  v!.length < 8 ? 'Min 8 characters required' : null,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmController,
              label: 'Confirm Password',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) =>
                  v != _newController.text ? 'Passwords do not match' : null,
            ),
          ],
        ),
      ),
      primaryButtonText: 'Change',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () {
        if (_formKey.currentState!.validate()) {
          context.read<AuthCubit>().updatePassword(
            currentPassword: _currentController.text,
            password: _newController.text,
            passwordConfirmation: _confirmController.text,
          );
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: validator ?? (v) => v!.isEmpty ? 'Required' : null,
    );
  }
}

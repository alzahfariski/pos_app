import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/constants/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const CustomDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final bool isAdmin =
        state is AuthAuthenticated && state.user.role == 'admin';
    final user = state is AuthAuthenticated ? state.user : null;

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(user),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              children: [
                _buildSectionTitle('OPERATIONS'),
                _buildDrawerItem(
                  icon: Icons.point_of_sale_rounded,
                  title: 'POS Application',
                  index: 0,
                  context: context,
                ),
                _buildDrawerItem(
                  icon: Icons.history_rounded,
                  title: 'Sales History',
                  index: 1,
                  context: context,
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('MANAGEMENT'),
                  _buildDrawerItem(
                    icon: Icons.inventory_2_rounded,
                    title: 'Products',
                    index: 2,
                    context: context,
                  ),
                  _buildDrawerItem(
                    icon: Icons.local_shipping_rounded,
                    title: 'Suppliers',
                    index: 3,
                    context: context,
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Purchases (In)',
                    index: 4,
                    context: context,
                  ),
                  _buildDrawerItem(
                    icon: Icons.edit_note_rounded,
                    title: 'Stock Adjustment',
                    index: 5,
                    context: context,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('ADMINISTRATION'),
                  _buildDrawerItem(
                    icon: Icons.people_alt_rounded,
                    title: 'Cashiers',
                    index: 6,
                    context: context,
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle('ACCOUNT'),
                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'My Profile',
                  index: isAdmin ? 7 : 2,
                  context: context,
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary500,
        // Optional: Add a subtle gradient or pattern
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              (user?.name != null && user!.name!.isNotEmpty)
                  ? user.name![0].toUpperCase()
                  : 'G',
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.primary500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user?.role?.toUpperCase() ?? 'GUEST',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.neutral400,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context); // Close drawer
          onItemSelected(index);
        },
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary500 : AppColors.neutral500,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary700 : AppColors.neutral800,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
        selected: isSelected,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'POS App v1.0.0',
            style: TextStyle(color: AppColors.neutral400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

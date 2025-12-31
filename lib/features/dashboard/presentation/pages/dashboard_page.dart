import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../products/presentation/pages/product_list_page.dart';
import '../../../pos/presentation/pages/pos_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../admin/presentation/pages/cashier_list_page.dart';
import '../../../suppliers/presentation/pages/supplier_list_page.dart';
import '../../../purchases/presentation/pages/purchase_list_page.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../pos/presentation/pages/pos_history_page.dart';
import '../widgets/custom_drawer.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Default to POS (Index 0)
  int _currentIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  void _buildPages() {
    // Always start with POS
    _pages.add(const PosPage());
    // POS History available for all roles
    _pages.add(const PosHistoryPage());

    // Check role
    final state = context.read<AuthCubit>().state;
    if (state is AuthAuthenticated && state.user.role == 'admin') {
      _pages.add(const ProductListPage());
      _pages.add(const SupplierListPage());
      _pages.add(const PurchaseListPage());
      _pages.add(const InventoryPage()); // Inventory Correction
      _pages.add(const CashierListPage());
    }

    // Always end with Profile
    _pages.add(const ProfilePage());
  }

  String _getPageTitle(int index) {
    if (index >= _pages.length) return 'POS System';
    final page = _pages[index];

    if (page is PosPage) return 'POS Application';
    if (page is PosHistoryPage) return 'POS History';
    if (page is ProductListPage) return 'Manage Products';
    if (page is SupplierListPage) return 'Manage Suppliers';
    if (page is PurchaseListPage) return 'Manage Purchases (Stock In)';
    if (page is InventoryPage) return 'Inventory Correction';
    if (page is CashierListPage) return 'Manage Cashiers';
    if (page is ProfilePage) return 'My Profile';

    return 'POS System';
  }

  @override
  Widget build(BuildContext context) {
    // Safety check
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _getPageTitle(_currentIndex),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: CustomDrawer(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
    );
  }
}

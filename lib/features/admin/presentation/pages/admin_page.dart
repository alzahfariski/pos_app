import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Products'),
              Tab(text: 'Supplier'),
              Tab(text: 'Cashier'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Manage Products')),
            Center(child: Text('Manage Suppliers')),
            Center(child: Text('Manage Cashiers')),
          ],
        ),
      ),
    );
  }
}

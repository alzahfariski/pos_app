import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../domain/entities/pos_transaction.dart';
import '../cubit/pos_history_cubit.dart';
import 'pos_history_filters.dart';

class PosHistoryPage extends StatelessWidget {
  const PosHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PosHistoryCubit>()..fetchHistory(),
      child: const _PosHistoryView(),
    );
  }
}

class _PosHistoryView extends StatefulWidget {
  const _PosHistoryView();

  @override
  State<_PosHistoryView> createState() => _PosHistoryViewState();
}

class _PosHistoryViewState extends State<_PosHistoryView> {
  PosTransaction? _selectedTransaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FocusDetector(
        onFocusGained: () {
          context.read<PosHistoryCubit>().fetchHistory();
        },
        child: BlocConsumer<PosHistoryCubit, PosHistoryState>(
          listener: (context, state) {
            if (state is PosHistoryFailure) {
              CustomToast.show(context, state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is PosHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PosHistoryLoaded) {
              if (state.allTransactions.isEmpty) {
                return const Center(
                  child: Text('No transaction history found.'),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 800) {
                    return _MobileLayout(state: state);
                  } else {
                    return _TabletLayout(
                      state: state,
                      selectedTransaction: _selectedTransaction,
                      onSelect: (transaction) {
                        setState(() {
                          _selectedTransaction = transaction;
                        });
                      },
                    );
                  }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// --- Layouts ---

class _MobileLayout extends StatelessWidget {
  final PosHistoryLoaded state;

  const _MobileLayout({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.black12)),
          ),
          child: const Row(
            children: [
              Text(
                'Transaction History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(Icons.history, color: Colors.grey),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: HistoryFilters(state: state),
        ),
        // List
        Expanded(
          child: state.filteredTransactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filteredTransactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _TransactionCard(
                      transaction: state.filteredTransactions[index],
                      isSelected: false,
                      onTap: () {
                        _showTransactionDetailSheet(
                          context,
                          state.filteredTransactions[index],
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showTransactionDetailSheet(
    BuildContext context,
    PosTransaction transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                child: _TransactionDetail(transaction: transaction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final PosHistoryLoaded state;
  final PosTransaction? selectedTransaction;
  final ValueChanged<PosTransaction> onSelect;

  const _TabletLayout({
    required this.state,
    required this.selectedTransaction,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left List
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: const Row(
                  children: [
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                child: HistoryFilters(state: state),
              ),
              Expanded(
                child: state.filteredTransactions.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.filteredTransactions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final transaction = state.filteredTransactions[index];
                          final isSelected =
                              selectedTransaction?.id == transaction.id;
                          return _TransactionCard(
                            transaction: transaction,
                            isSelected: isSelected,
                            onTap: () => onSelect(transaction),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        // Right Detail
        Expanded(
          flex: 6,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(-4, 0),
                ),
              ],
            ),
            child: selectedTransaction == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: AppColors.neutral300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select a transaction to view details',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _TransactionDetail(
                        transaction: selectedTransaction!,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// --- Components ---

class _TransactionCard extends StatelessWidget {
  final PosTransaction transaction;
  final bool isSelected;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
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
    ).format(DateTime.parse(transaction.createdAt));

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
                color: Colors.black.withAlpha(5),
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
                  transaction.invoiceNumber.isNotEmpty
                      ? transaction.invoiceNumber
                      : '#${transaction.id}',
                ),
                Text(
                  currencyFormatter.format(transaction.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.cashierName,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDetail extends StatelessWidget {
  final PosTransaction transaction;

  const _TransactionDetail({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateStr = DateFormat(
      'dd MMMM yyyy, HH:mm',
    ).format(DateTime.parse(transaction.createdAt));

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Receipt Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success500,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transaction Successful',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.success500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(transaction.totalAmount),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Info Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50], // Light background for info
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _InfoRow(
                  label: 'Invoice No.',
                  value: transaction.invoiceNumber.isNotEmpty
                      ? transaction.invoiceNumber
                      : '#${transaction.id}',
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Date', value: dateStr),
                const SizedBox(height: 12),
                _InfoRow(label: 'Cashier', value: transaction.cashierName),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Payment Method',
                  value: transaction.paymentMethod,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Order Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Items List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transaction.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = transaction.items[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${item.qty} x ${currencyFormatter.format(item.priceSnapshot)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormatter.format(item.subtotal),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Summary
          _SummaryRow(
            label: 'Subtotal',
            value: currencyFormatter.format(transaction.totalAmount),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Payment',
            value: currencyFormatter.format(transaction.paymentAmount),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Change',
            value: currencyFormatter.format(transaction.changeAmount),
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? Colors.black : Colors.grey,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? AppColors.primary500 : Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}

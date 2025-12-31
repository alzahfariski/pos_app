import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/pos_history_cubit.dart';

class HistoryFilters extends StatelessWidget {
  final PosHistoryLoaded state;

  const HistoryFilters({super.key, required this.state});

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: state.startDate != null
          ? DateTimeRange(
              start: state.startDate!,
              end: state.endDate ?? state.startDate!,
            )
          : null,
    );

    if (picked != null && context.mounted) {
      context.read<PosHistoryCubit>().setFilter(
        'custom',
        start: picked.start,
        end: picked.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (value) => context.read<PosHistoryCubit>().search(value),
            decoration: InputDecoration(
              hintText: 'Search invoice #...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                isSelected: state.filterType == 'all',
                onSelected: (_) =>
                    context.read<PosHistoryCubit>().setFilter('all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Today',
                isSelected: state.filterType == 'today',
                onSelected: (_) =>
                    context.read<PosHistoryCubit>().setFilter('today'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'This Month',
                isSelected: state.filterType == 'month',
                onSelected: (_) =>
                    context.read<PosHistoryCubit>().setFilter('month'),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(
                  state.filterType == 'custom' && state.startDate != null
                      ? '${DateFormat('dd/MM').format(state.startDate!)} - ${DateFormat('dd/MM').format(state.endDate ?? state.startDate!)}'
                      : 'Custom Date',
                ),
                avatar: const Icon(Icons.calendar_today, size: 16),
                backgroundColor: state.filterType == 'custom'
                    ? AppColors.primary50
                    : null,
                labelStyle: TextStyle(
                  color: state.filterType == 'custom'
                      ? AppColors.primary500
                      : null,
                ),
                onPressed: () => _selectDate(context),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary50,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary500 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: isSelected ? const BorderSide(color: AppColors.primary500) : null,
    );
  }
}

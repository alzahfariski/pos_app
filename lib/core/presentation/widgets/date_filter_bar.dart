import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

enum DateFilterType { all, today, thisMonth, custom }

class DateFilterBar extends StatelessWidget {
  final DateFilterType selectedType;
  final DateTimeRange? customRange;
  final Function(DateFilterType type, DateTimeRange? range) onFilterChanged;

  const DateFilterBar({
    super.key,
    required this.selectedType,
    this.customRange,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All Time',
            isSelected: selectedType == DateFilterType.all,
            onTap: () => onFilterChanged(DateFilterType.all, null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Today',
            isSelected: selectedType == DateFilterType.today,
            onTap: () {
              final now = DateTime.now();
              final start = DateTime(now.year, now.month, now.day);
              final end = start
                  .add(const Duration(days: 1))
                  .subtract(const Duration(milliseconds: 1));
              onFilterChanged(
                DateFilterType.today,
                DateTimeRange(start: start, end: end),
              );
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Month',
            isSelected: selectedType == DateFilterType.thisMonth,
            onTap: () {
              final now = DateTime.now();
              final start = DateTime(now.year, now.month, 1);
              final end = DateTime(
                now.year,
                now.month + 1,
                1,
              ).subtract(const Duration(milliseconds: 1));
              onFilterChanged(
                DateFilterType.thisMonth,
                DateTimeRange(start: start, end: end),
              );
            },
          ),
          const SizedBox(width: 8),
          ActionChip(
            avatar: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              selectedType == DateFilterType.custom && customRange != null
                  ? '${DateFormat('dd MMM').format(customRange!.start)} - ${DateFormat('dd MMM').format(customRange!.end)}'
                  : 'Custom Date',
            ),
            backgroundColor: selectedType == DateFilterType.custom
                ? AppColors.primary50
                : Colors.white,
            side: BorderSide(
              color: selectedType == DateFilterType.custom
                  ? AppColors.primary500
                  : Colors.grey.shade300,
            ),
            labelStyle: TextStyle(
              color: selectedType == DateFilterType.custom
                  ? AppColors.primary500
                  : Colors.black87,
              fontWeight: selectedType == DateFilterType.custom
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDateRange: customRange,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary500,
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                // Ensure end of day for the end date
                final end = picked.end
                    .add(const Duration(days: 1))
                    .subtract(const Duration(milliseconds: 1));
                // Ensure start of day for start date (usually picker does this but safe to match)
                final start = DateTime(
                  picked.start.year,
                  picked.start.month,
                  picked.start.day,
                );

                onFilterChanged(
                  DateFilterType.custom,
                  DateTimeRange(start: start, end: end), // Using adjusted range
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary50,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary500 : Colors.grey.shade300,
        width: 1,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary500 : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      showCheckmark: false,
    );
  }
}

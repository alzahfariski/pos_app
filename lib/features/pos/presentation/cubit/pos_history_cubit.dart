import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pos_transaction.dart';
import '../../domain/repositories/pos_repository.dart';

abstract class PosHistoryState extends Equatable {
  const PosHistoryState();
  @override
  List<Object?> get props => [];
}

class PosHistoryInitial extends PosHistoryState {}

class PosHistoryLoading extends PosHistoryState {}

class PosHistoryLoaded extends PosHistoryState {
  final List<PosTransaction> allTransactions;
  final List<PosTransaction> filteredTransactions;
  final String searchQuery;
  final String filterType; // 'all', 'today', 'month', 'custom'
  final DateTime? startDate;
  final DateTime? endDate;

  const PosHistoryLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    this.searchQuery = '',
    this.filterType = 'all',
    this.startDate,
    this.endDate,
  });

  PosHistoryLoaded copyWith({
    List<PosTransaction>? allTransactions,
    List<PosTransaction>? filteredTransactions,
    String? searchQuery,
    String? filterType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PosHistoryLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    allTransactions,
    filteredTransactions,
    searchQuery,
    filterType,
    startDate,
    endDate,
  ];
}

class PosHistoryFailure extends PosHistoryState {
  final String message;
  const PosHistoryFailure(this.message);
  @override
  List<Object> get props => [message];
}

class PosHistoryCubit extends Cubit<PosHistoryState> {
  final PosRepository repository;

  PosHistoryCubit({required this.repository}) : super(PosHistoryInitial());

  Future<void> fetchHistory() async {
    emit(PosHistoryLoading());
    try {
      final transactions = await repository.getPosHistory();
      // Sort by newest first
      transactions.sort(
        (a, b) =>
            DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)),
      );
      emit(
        PosHistoryLoaded(
          allTransactions: transactions,
          filteredTransactions: transactions,
        ),
      );
    } catch (e) {
      emit(PosHistoryFailure(e.toString()));
    }
  }

  void search(String query) {
    if (state is PosHistoryLoaded) {
      final currentState = state as PosHistoryLoaded;
      emit(currentState.copyWith(searchQuery: query));
      _applyFilters();
    }
  }

  void setFilter(String type, {DateTime? start, DateTime? end}) {
    if (state is PosHistoryLoaded) {
      final currentState = state as PosHistoryLoaded;
      emit(
        currentState.copyWith(filterType: type, startDate: start, endDate: end),
      );
      _applyFilters();
    }
  }

  void _applyFilters() {
    if (state is PosHistoryLoaded) {
      final currentState = state as PosHistoryLoaded;
      var filtered = List<PosTransaction>.from(currentState.allTransactions);

      // Apply Date Filter
      if (currentState.filterType != 'all') {
        final now = DateTime.now();
        DateTime start;
        DateTime end;

        if (currentState.filterType == 'today') {
          start = DateTime(now.year, now.month, now.day);
          end = start
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1));
        } else if (currentState.filterType == 'month') {
          start = DateTime(now.year, now.month, 1);
          end = DateTime(
            now.year,
            now.month + 1,
            1,
          ).subtract(const Duration(milliseconds: 1));
        } else if (currentState.filterType == 'custom' &&
            currentState.startDate != null) {
          start = currentState.startDate!;
          end =
              currentState.endDate ??
              start
                  .add(const Duration(days: 1))
                  .subtract(const Duration(milliseconds: 1));
          // Ensure end includes the full day if it's the same as start or just a date
          if (currentState.endDate != null) {
            end = DateTime(end.year, end.month, end.day, 23, 59, 59);
          } else {
            end = DateTime(start.year, start.month, start.day, 23, 59, 59);
          }
          // Use the start at 00:00
          start = DateTime(start.year, start.month, start.day);
        } else {
          // Fallback
          start = DateTime(1970);
          end = DateTime(3000);
        }

        filtered = filtered.where((t) {
          final tDate = DateTime.parse(t.createdAt);
          return tDate.isAfter(start) && tDate.isBefore(end);
        }).toList();
      }

      // Apply Search
      if (currentState.searchQuery.isNotEmpty) {
        final query = currentState.searchQuery.toLowerCase();
        filtered = filtered.where((t) {
          return t.invoiceNumber.toLowerCase().contains(query) ||
              t.id.toString().contains(query);
        }).toList();
      }

      emit(currentState.copyWith(filteredTransactions: filtered));
    }
  }
}

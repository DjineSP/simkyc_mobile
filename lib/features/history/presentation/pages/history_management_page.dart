import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/widgets/app_message_dialog.dart';

class HistoryManagementPage extends StatefulWidget {
  const HistoryManagementPage({super.key});

  @override
  State<HistoryManagementPage> createState() => _HistoryManagementPageState();
}

class _HistoryManagementPageState extends State<HistoryManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  late final List<_Customer> _allCustomers;
  String _query = '';
  bool _isLoading = true;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Génération simulée
    _allCustomers = List.generate(
      100,
          (index) => _Customer(
        name: 'Client ${index + 1}',
        msisdn: '6${(90000000 + index).toString()}',
        idNumber: 'CM${1000 + index}',
        statusIndex: index % 3,
        createdAt: DateTime.now().subtract(Duration(days: index % 30)),
      ),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  List<_Customer> get _filteredCustomers {
    return _allCustomers.where((c) {
      final q = _query.toLowerCase();
      final matchesText = c.name.toLowerCase().contains(q) ||
          c.msisdn.contains(q) ||
          c.idNumber.toLowerCase().contains(q);

      bool matchesDate = true;
      if (_selectedDateRange != null) {
        matchesDate = c.createdAt.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            c.createdAt.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }
      return matchesText && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final displayedList = _filteredCustomers;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l10n.history_search_hint,
                    prefixIcon: const Icon(Icons.search),
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDateSelector(theme, l10n),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: SkeletonizerConfig(
                data: SkeletonizerConfigData(
                  effect: ShimmerEffect(
                    baseColor: isDark
                        ? scheme.surfaceContainerHighest
                        : const Color(0xFFEDEFF3),
                    highlightColor: isDark
                        ? scheme.surface
                        : Colors.white,
                  ),
                ),
                child: Skeletonizer(
                  enabled: _isLoading,
                  child: displayedList.isEmpty && !_isLoading
                      ? _buildEmptyState(l10n)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _isLoading ? 6 : displayedList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (_isLoading) return const _CustomerCardPlaceholder();
                            return _CustomerCard(customer: displayedList[index]);
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme, var l10n) {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2023),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: theme.copyWith(colorScheme: theme.colorScheme.copyWith(primary: AppColors.primary)),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _selectedDateRange = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range_rounded, size: 18, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDateRange == null
                    ? l10n.history_date_all
                    : l10n.history_date_range(
                  DateFormat('dd/MM/yy').format(_selectedDateRange!.start),
                  DateFormat('dd/MM/yy').format(_selectedDateRange!.end),
                ),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            if (_selectedDateRange != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDateRange = null),
                child: const Icon(Icons.cancel, size: 18, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(var l10n) {
    return Center(child: Text(l10n.history_empty, style: const TextStyle(color: AppColors.muted)));
  }
}

class _Customer {
  final String name;
  final String msisdn;
  final String idNumber;
  final int statusIndex; // 0: Actif, 1: Suspendu, 2: Désactivé
  final DateTime createdAt;
  const _Customer({required this.name, required this.msisdn, required this.idNumber, required this.statusIndex, required this.createdAt});
}

class _CustomerCard extends StatelessWidget {
  final _Customer customer;
  const _CustomerCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final statuses = [l10n.history_status_active, l10n.history_status_suspended, l10n.history_status_inactive];
    final colors = [Colors.green, Colors.orange, Colors.red];
    final color = colors[customer.statusIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(statuses[customer.statusIndex], style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('MSISDN: ${customer.msisdn}', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          Text(DateFormat('dd MMMM yyyy').format(customer.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 16),
          Row(
            children: [
              _btn(context, l10n.history_btn_details, false),
              const SizedBox(width: 8),
              _btn(context, l10n.history_btn_reactivate, false),
              const SizedBox(width: 8),
              _btn(context, l10n.history_btn_update, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String label, bool isPrimary) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          side: isPrimary ? BorderSide.none : BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _CustomerCardPlaceholder extends StatelessWidget {
  const _CustomerCardPlaceholder();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
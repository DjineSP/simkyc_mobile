import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import '../../data/models/history_item.dart';
import '../providers/history_provider.dart';

class HistoryManagementPage extends ConsumerStatefulWidget {
  const HistoryManagementPage({super.key});

  @override
  ConsumerState<HistoryManagementPage> createState() => _HistoryManagementPageState();
}

class _HistoryManagementPageState extends ConsumerState<HistoryManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 250) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final historyState = ref.watch(historyProvider);
    final displayedList = historyState.items;
    final isLoading = historyState.isLoading;

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
                  onChanged: (v) => ref.read(historyProvider.notifier).setQuery(v),
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
              onRefresh: () => ref.read(historyProvider.notifier).refresh(),
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
                  enabled: isLoading,
                  child: displayedList.isEmpty && !isLoading
                      ? _buildEmptyState(l10n)
                      : ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: isLoading
                              ? 6
                              : displayedList.length + (historyState.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (isLoading) return const _HistoryItemCardPlaceholder();
                            if (index >= displayedList.length) {
                              return const _HistoryLoadingMoreCard();
                            }

                            final prev = index > 0 ? displayedList[index - 1] : null;
                            final item = displayedList[index];

                            final showHeader = prev == null ||
                                !_isSameDay(prev.createdAt, item.createdAt);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      DateFormat('dd MMMM yyyy').format(item.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                                      ),
                                    ),
                                  ),
                                _HistoryItemCard(item: item),
                              ],
                            );
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
        if (picked != null) {
          setState(() => _selectedDateRange = picked);
          await ref.read(historyProvider.notifier).setDateRange(picked);
        }
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
                onTap: () async {
                  setState(() => _selectedDateRange = null);
                  await ref.read(historyProvider.notifier).setDateRange(null);
                },
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

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _HistoryItemCard extends StatelessWidget {
  final HistoryItem item;
  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final statuses = [l10n.history_status_active, l10n.history_status_suspended, l10n.history_status_inactive];
    final colors = [Colors.green, Colors.orange, Colors.red];
    final color = colors[item.statusIndex];

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
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(statuses[item.statusIndex], style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('MSISDN: ${item.msisdn}', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          Text(DateFormat('HH:mm').format(item.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
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

class _HistoryItemCardPlaceholder extends StatelessWidget {
  const _HistoryItemCardPlaceholder();
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

class _HistoryLoadingMoreCard extends StatelessWidget {
  const _HistoryLoadingMoreCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
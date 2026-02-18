import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import '../providers/history_provider.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/entities/history_item.dart';
import '../../../../core/utils/string_utils.dart';
import 'history_detail_page.dart';

class HistoryManagementPage extends ConsumerStatefulWidget {
  const HistoryManagementPage({super.key});

  @override
  ConsumerState<HistoryManagementPage> createState() => _HistoryManagementPageState();
}

class _HistoryManagementPageState extends ConsumerState<HistoryManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => ref.read(historyProvider.notifier).setQuery(v),
                  decoration: InputDecoration(
                    hintText: l10n.history_search_hint,
                    prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                    filled: true,
                    fillColor: isDark ? AppColors.slate : AppColors.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),

                const SizedBox(height: 10),
                _buildDateSelector(theme, l10n),
                const SizedBox(height: 12),
                _buildFilterChips(l10n),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(historyProvider.notifier).refresh(),
              color: AppColors.primary,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: SkeletonizerConfig(
                data: SkeletonizerConfigData(
                  effect: ShimmerEffect(
                    baseColor: isDark
                        ? AppColors.darkSurface
                        : const Color(0xFFE0E0E0),
                    highlightColor: isDark
                        ? AppColors.slate
                        : const Color(0xFFF5F5F5),
                  ),
                ),
                child: Skeletonizer(
                  enabled: isLoading,
                  child: displayedList.isEmpty && !isLoading
                      ? _buildEmptyState(l10n)
                      : ListView.separated(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
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
                                !_isSameDay(prev.operationDate, item.operationDate);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 8, left: 4),
                                    child: Text(
                                      DateFormat('dd MMMM yyyy', l10n.localeName).format(item.operationDate).toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.muted,
                                        letterSpacing: 1.0,
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

  Widget _buildDateSelector(ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final historyState = ref.watch(historyProvider);
    final dateRange = historyState.dateRange;

    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
          initialDateRange: dateRange != null 
            ? DateTimeRange(start: dateRange.start, end: dateRange.end) 
            : null,
          builder: (context, child) => Theme(
            data: theme.copyWith(colorScheme: theme.colorScheme.copyWith(primary: AppColors.primary)),
            child: child!,
          ),
        );
        if (picked != null) {
          ref.read(historyProvider.notifier).setDateRange(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.slate : AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _getDateLabel(dateRange, l10n),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
              ),
            ),
            if (dateRange != null)
              GestureDetector(
                onTap: () {
                   // Optional: Allow clearing to reset to default 30 days?
                   // Provider handles null by resetting to default.
                   ref.read(historyProvider.notifier).setDateRange(null);
                },
                child: const Icon(Icons.refresh, size: 18, color: AppColors.primary), // Changed icon to refresh/reset hint
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final historyState = ref.watch(historyProvider);
    final selectedFilter = historyState.filterType;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _FilterChipCustom(
              label: l10n.history_filter_all,
              isSelected: selectedFilter == null,
              onSelected: (s) {
                ref.read(historyProvider.notifier).setFilterType(null);
              },
            ),
          ),
          ...HistoryActionType.values.map((type) {
            String label;
            switch (type) {
              case HistoryActionType.activation:
                label = l10n.history_filter_activation;
                break;
              case HistoryActionType.reactivation:
                label = l10n.history_filter_reactivation;
                break;
              case HistoryActionType.update:
                label = l10n.history_filter_update;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _FilterChipCustom(
                label: label,
                isSelected: selectedFilter == type,
                onSelected: (s) {
                  ref.read(historyProvider.notifier).setFilterType(s ? type : null);
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(var l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.muted.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(l10n.history_empty, style: const TextStyle(color: AppColors.muted, fontSize: 16)),
        ],
      ),
    );
  }

  String _getDateLabel(dynamic dateRange, AppLocalizations l10n) {
    if (dateRange == null) return l10n.history_date_all;
    
    // Check for default 30 days
    final now = DateTime.now();
    // dateRange is DateTimeRangeFilter from HistoryState.
    final start = dateRange.start as DateTime;
    final end = dateRange.end as DateTime;

    final isDefaultEnd = _isSameDay(end, now);
    final days = end.difference(start).inDays;

    if (isDefaultEnd && days == 30) {
      return l10n.reports_period_30d;
    }

    return l10n.history_date_range(
      DateFormat('dd/MM/yy').format(start),
      DateFormat('dd/MM/yy').format(end),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _FilterChipCustom extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _FilterChipCustom({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.muted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final HistoryItem item;
  const _HistoryItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    IconData icon;
    Color color; // Semantic color for the icon only
    switch (item.type) {
      case HistoryActionType.activation:
        icon = Icons.add_circle_outline_rounded;
        color = AppColors.success;
        break;
      case HistoryActionType.reactivation:
        icon = Icons.refresh_rounded;
        color = Colors.blue;
        break;
      case HistoryActionType.update:
        icon = Icons.edit_outlined;
        color = Colors.orange;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        // Bordure cohérente avec les champs (pas d'opacité en dark mode pour matcher exactement)
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icone
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                
                // MSISDN + Client Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringUtils.formatPhone(
                          item.details?.numeroTelephoneClient?.isNotEmpty == true
                              ? item.details!.numeroTelephoneClient!
                              : item.msisdn
                        ),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            fontFamily: 'Monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        item.clientName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Date
                 Text(
                  DateFormat('HH:mm').format(item.operationDate),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.muted),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.5)),
            const SizedBox(height: 12),
            
            // Info + Badge + Bouton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 _StatusBadge(status: item.status),

                 // Bouton Détails
                   InkWell(
                   onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailPage(item: item)
                        )
                      );
                   },
                   borderRadius: BorderRadius.circular(8),
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     decoration: BoxDecoration(
                       color: theme.colorScheme.onSurface.withOpacity(0.05),
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                     ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(
                           l10n.history_btn_details,
                           style: TextStyle(
                             fontSize: 12, 
                             fontWeight: FontWeight.w600, 
                             color: theme.colorScheme.onSurface.withOpacity(0.8)
                           ),
                         ),
                         const SizedBox(width: 4),
                         Icon(Icons.arrow_forward_rounded, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                       ],
                     ),
                   ),
                 )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final HistoryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String label;
    switch (status) {
      case HistoryStatus.active:
        label = l10n.history_status_active;
        break;
      case HistoryStatus.suspended:
        label = l10n.history_status_suspended;
        break;
      case HistoryStatus.pending:
      default:
        label = l10n.history_status_pending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HistoryItemCardPlaceholder extends StatelessWidget {
  const _HistoryItemCardPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Bone(
      height: 160,
      borderRadius: BorderRadius.circular(16),
    );
  }
}

class _HistoryLoadingMoreCard extends StatelessWidget {
  const _HistoryLoadingMoreCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

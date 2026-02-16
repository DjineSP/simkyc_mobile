import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/reports_data.dart';
import '../providers/reports_provider.dart';

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  String? _periodValue;

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);

  Future<void> _applyPeriod(String value, AppLocalizations l10n) async {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (value == l10n.reports_period_today) {
      start = _startOfDay(now);
      end = _endOfDay(now);
    } else if (value == l10n.reports_period_30d) {
      start = _startOfDay(now.subtract(const Duration(days: 29)));
      end = _endOfDay(now);
    } else {
      // default 7d
      start = _startOfDay(now.subtract(const Duration(days: 6)));
      end = _endOfDay(now);
    }

    await ref.read(reportsProvider.notifier).setDateRange(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final state = ref.watch(reportsProvider);
    final isLoading = state.isLoading;
    final data = state.data;

    // Initialisation de la période par défaut basée sur l10n
    _periodValue ??= l10n.reports_period_today;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(reportsProvider.notifier).refresh(),
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              _buildHeader(l10n, theme),
              Skeletonizer(
                enabled: isLoading,
                child: _buildKpiGrid(l10n, data),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.reports_section_reason,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Skeletonizer(
                  enabled: isLoading,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _ReasonRow(reason: l10n.reports_reason_customer, count: data?.reasons[ReportReasonType.customer] ?? 0),
                      _ReasonRow(reason: l10n.reports_reason_sim_change, count: data?.reasons[ReportReasonType.simChange] ?? 0),
                      _ReasonRow(reason: l10n.reports_reason_tech, count: data?.reasons[ReportReasonType.tech] ?? 0),
                      _ReasonRow(reason: l10n.reports_reason_fraud, count: data?.reasons[ReportReasonType.fraud] ?? 0),
                      _ReasonRow(reason: l10n.reports_reason_other, count: data?.reasons[ReportReasonType.other] ?? 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            l10n.reports_title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _periodValue,
            underline: const SizedBox(),
            dropdownColor: theme.colorScheme.surface,
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            icon: Icon(Icons.keyboard_arrow_down, size: 20, color: theme.colorScheme.primary),
            // CORRECTION : Spécifier explicitement le type du map
            items: [
              l10n.reports_period_today,
              l10n.reports_period_7d,
              l10n.reports_period_30d,
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _periodValue = v);
              _applyPeriod(v, l10n);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(var l10n, ReportsData? data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: l10n.reports_kpi_activations,
              value: (data?.activations ?? 0).toString(),
              accentColor: Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: l10n.reports_kpi_reactivations,
              value: (data?.reactivations ?? 0).toString(),
              accentColor: Colors.blue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SummaryCard(
              label: l10n.reports_kpi_updates,
              value: (data?.updates ?? 0).toString(),
              accentColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  final String reason;
  final int count;

  const _ReasonRow({required this.reason, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              reason,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
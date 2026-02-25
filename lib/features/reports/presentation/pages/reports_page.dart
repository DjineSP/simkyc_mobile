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
              Expanded(
                child: Skeletonizer(
                  enabled: isLoading,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final int acts = data?.activations ?? 0;
                      final int reacts = data?.reactivations ?? 0;
                      final int upds = data?.updates ?? 0;
                      final int totalOps = acts + reacts + upds;

                      // Responsive : Ajuster le nombre de colonnes selon la largeur
                      int crossAxisCount = 3; // Par défaut 3 jauges (une par opération)
                      double width = constraints.maxWidth;
                      if (width < 600) {
                        crossAxisCount = 2; // Sur petit écran, 2 par ligne pour être lisible
                      }
                      
                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _GaugeCard(
                            label: l10n.reports_kpi_activations, 
                            value: acts, 
                            total: totalOps, 
                            color: Colors.green
                          ),
                          _GaugeCard(
                            label: l10n.reports_kpi_reactivations, 
                            value: reacts, 
                            total: totalOps, 
                            color: Colors.blue
                          ),
                          _GaugeCard(
                            label: l10n.reports_kpi_updates, 
                            value: upds, 
                            total: totalOps, 
                            color: Colors.orange
                          ),
                        ],
                      );
                    }
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
          Expanded(
            child: Text(
              l10n.reports_title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
}

class _GaugeCard extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _GaugeCard({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Eviter division par zéro
    final double percentage = total > 0 ? (value / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fond de la jauge
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.white10 : Colors.grey.shade100,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Valeur animée
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percentage),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CircularProgressIndicator(
                        value: val,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeCap: StrokeCap.round,
                      ),
                    );
                  },
                ),
                // Texte central
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
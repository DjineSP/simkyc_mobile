import 'package:flutter/material.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';
import '../components/activation_helpers.dart';

class StepCustomerInfo extends StatelessWidget {
  final Map<String, TextEditingController> ctrls;
  final Map<String, FocusNode> nodes;
  final Map<String, String?> errors;
  final bool isMale;
  final Function(bool) onGenderChanged;

  const StepCustomerInfo({
    super.key,
    required this.ctrls,
    required this.nodes,
    required this.errors,
    required this.isMale,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOM ET PRÉNOM
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildField(context, l10n.step_cust_lastname, 'lastName', hint: l10n.step_cust_hint_name),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(context, l10n.step_cust_firstname, 'firstName', hint: l10n.step_cust_hint_firstname),
              ),
            ],
          ),

          // DATE DE NAISSANCE
          LabelText(l10n.step_cust_dob),
          TextField(
            controller: ctrls['dob'],
            focusNode: nodes['dob'],
            readOnly: true,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            decoration: inputDec(
                context: context,
                hint: l10n.step_cust_hint_date,
                error: errors['dob'],
                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18)
            ),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),

          // LIEU DE NAISSANCE
          _buildField(context, l10n.step_cust_pob, 'pob', hint: l10n.step_cust_hint_pob),

          // GENRE
          LabelText(l10n.step_cust_gender),
          Row(
            children: [
              _radio(l10n.step_cust_male, true, theme),
              _radio(l10n.step_cust_female, false, theme),
            ],
          ),

          Divider(height: 32, thickness: 1, color: theme.dividerColor.withOpacity(0.1)),

          // ADRESSES ET PROFESSION
          _buildField(context, l10n.step_cust_geo, 'geo', hint: l10n.step_cust_hint_geo),
          _buildField(context, l10n.step_cust_post, 'post', hint: l10n.step_cust_hint_post),
          _buildField(context, l10n.step_cust_email, 'email', hint: l10n.step_cust_hint_email),
          _buildField(context, l10n.step_cust_job, 'job', hint: l10n.step_cust_hint_job),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // ~18 ans
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppColors.primary, // Couleur des boutons et du cercle de sélection
              onPrimary: Colors.white,
              surface: theme.colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ctrls['dob']!.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  Widget _buildField(BuildContext context, String label, String key, {required String hint}) {
    final controller = ctrls[key];
    final node = nodes[key];
    final error = errors[key];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(label),
        TextField(
          controller: controller,
          focusNode: node,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          decoration: inputDec(
              context: context,
              hint: hint,
              error: error
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _radio(String text, bool value, ThemeData theme) => Expanded(
    child: RadioListTile<bool>(
      title: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          )
      ),
      value: value,
      groupValue: isMale,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onChanged: (val) => onGenderChanged(val!),
    ),
  );
}
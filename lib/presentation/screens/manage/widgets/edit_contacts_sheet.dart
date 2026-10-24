import 'package:flutter/material.dart';

import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_overlays.dart';

Future<void> showEditContactsSheet(
  BuildContext context, {
  required String primary,
  required String secondary,
  required void Function(String primary, String secondary) onSave,
}) => showAppBottomSheet(
  context,
  builder: (_) =>
      EditContactsSheet(primary: primary, secondary: secondary, onSave: onSave),
);

class EditContactsSheet extends StatefulWidget {
  final String primary;
  final String secondary;
  final void Function(String primary, String secondary) onSave;

  const EditContactsSheet({
    super.key,
    required this.primary,
    required this.secondary,
    required this.onSave,
  });

  @override
  State<EditContactsSheet> createState() => _EditContactsSheetState();
}

class _EditContactsSheetState extends State<EditContactsSheet> {
  late final _primary = TextEditingController(text: widget.primary);
  late final _secondary = TextEditingController(text: widget.secondary);

  @override
  void dispose() {
    _primary.dispose();
    _secondary.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.pop(context);
    widget.onSave(_primary.text.trim(), _secondary.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit emergency contacts',
              style: AppTextStyles.titleWithColor(context),
            ),
            Text(
              'Primary is called first. Secondary is the backup.',
              style: AppTextStyles.metaWithColor(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _primary,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Primary number',
                prefixIcon: Icon(Icons.phone_in_talk_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _secondary,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'Secondary number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Save contacts', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../blocs/link_device/link_device_bloc.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/app_text_field.dart';

class LinkDeviceBottomSheet extends StatefulWidget {
  const LinkDeviceBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context,
      builder: (_) => BlocProvider(
        create: (_) => sl<LinkDeviceBloc>(),
        child: const LinkDeviceBottomSheet(),
      ),
    );
  }

  @override
  State<LinkDeviceBottomSheet> createState() => _LinkDeviceBottomSheetState();
}

class _LinkDeviceBottomSheetState extends State<LinkDeviceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();

  // TODO(logic): business data. Owner type is fixed to 'person' for now;
  // move to the bloc/event default.
  static const _ownerType = 'person';

  @override
  void dispose() {
    _serialNumberController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LinkDeviceBloc>().add(
      LinkDeviceSubmitted(
        ownerType: _ownerType,
        deviceSerialNo: _serialNumberController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<LinkDeviceBloc, LinkDeviceState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == LinkDeviceStatus.success) {
          AppSnackBar.success(context, 'Device linked');
          // DeviceListScreen's _navigateAndRefresh handles the reload.
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == LinkDeviceStatus.loading;
        final errorMessage = state.status == LinkDeviceStatus.error
            ? state.errorMessage
            : null;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md + bottomInset,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.xs,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Link your device',
                            style: AppTextStyles.titleWithColor(context),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          visualDensity: VisualDensity.compact,
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          icon: Icon(AppIcons.close),
                        ),
                      ],
                    ),
                    Text(
                      'Enter the serial number printed on the back of your smart '
                      'card tracker or on its packaging box.',
                      style: AppTextStyles.bodyWithColor(context),
                    ),
                  ],
                ),
                if (errorMessage != null) _ErrorBanner(message: errorMessage),
                AppTextField(
                  controller: _serialNumberController,
                  label: 'Device Serial Number *',
                  hint: 'sqP4YT8TR',
                  // prefixIcon: AppIcons.serialNumber,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Serial number is required to link the device.';
                    }
                    return null;
                  },
                ),
                AppButton(
                  label: 'Link Device',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// TODO(shared): identical to the private _ErrorBanner in
// link_member_by_phone_screen.dart. It is now used by 2+ files, so move it to
// widgets/ (for example AppErrorBanner) and use it in both.
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: AppColors.dangerContainer,
      padding: AppSpacing.smAll,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Icon(AppIcons.error, size: AppSize.icon, color: AppColors.danger),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyWithColor(
                context,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

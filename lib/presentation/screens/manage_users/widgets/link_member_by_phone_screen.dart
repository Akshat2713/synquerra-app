import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/app_router.dart';
import '../../../blocs/manage_users/manage_users_bloc.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_overlays.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/user_avatar.dart';

class LinkMemberByPhoneBottomSheet extends StatefulWidget {
  const LinkMemberByPhoneBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<ManageUsersBloc>();
    return showAppBottomSheet<void>(
      context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const LinkMemberByPhoneBottomSheet(),
      ),
    );
  }

  @override
  State<LinkMemberByPhoneBottomSheet> createState() =>
      _LinkMemberByPhoneBottomSheetState();
}

class _LinkMemberByPhoneBottomSheetState
    extends State<LinkMemberByPhoneBottomSheet> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedRelationship = 'Friend';

  // TODO(logic): the bloc has no "link succeeded" signal. Replace this flag
  // with a state/event from the bloc.
  bool _linking = false;

  // TODO(logic): business data. Note these are capitalised ('Friend') while
  // the Add form sends lowercase ('child'). Confirm what the API expects.
  static const _relationshipTypes = [
    'Friend',
    'Parent',
    'Child',
    'Sibling',
    'Spouse',
    'Relative',
    'Other',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _search() {
    if (!_phoneFormKey.currentState!.validate()) return;
    context.read<ManageUsersBloc>().add(
      ManageUsersSearchByPhoneRequested(_phoneController.text.trim()),
    );
  }

  void _confirmLink() {
    _linking = true;
    context.read<ManageUsersBloc>().add(
      ManageUsersConfirmLinkRequested(_selectedRelationship),
    );
  }

  void _searchAgain() =>
      context.read<ManageUsersBloc>().add(const ManageUsersClearFoundPerson());

  void _navigateToCreateUser() {
    final bloc = context.read<ManageUsersBloc>();
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.addMember, arguments: bloc);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<ManageUsersBloc, ManageUsersState>(
      // Only while a link is in flight: failure stays inline, success closes.
      listenWhen: (p, c) =>
          _linking &&
          c is ManageUsersLoaded &&
          (c.errorMessage != null || p is ManageUsersLoading),
      listener: (context, state) {
        _linking = false;
        if (state is ManageUsersLoaded && state.errorMessage == null) {
          AppSnackBar.success(context, 'Member linked');
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final loaded = state is ManageUsersLoaded ? state : null;
        final isSearching = loaded?.isSearching ?? false;
        final isProcessing = loaded?.isProcessing ?? false;
        final foundPerson = loaded?.foundPerson;
        final errorMessage = loaded?.errorMessage;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Link Member',
                      style: AppTextStyles.titleWithColor(context),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(AppIcons.close),
                  ),
                ],
              ),
              Text(
                'Enter the registered phone number of the member you want to link.',
                style: AppTextStyles.bodyWithColor(context),
              ),
              if (errorMessage != null) _ErrorBanner(message: errorMessage),
              if (foundPerson == null) ...[
                Form(
                  key: _phoneFormKey,
                  child: AppTextField(
                    controller: _phoneController,
                    label: 'Phone Number *',
                    hint: '+917878787878',
                    prefixIcon: AppIcons.phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    // TODO(logic): phone validation rule.
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (v.trim().length < 10) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ),
                AppButton(
                  label: 'Search',
                  onPressed: _search,
                  isLoading: isSearching,
                ),
              ] else ...[
                AppCard(
                  tint: AppColors.primaryContainer(context),
                  padding: AppSpacing.smAll,
                  child: Row(
                    spacing: AppSpacing.smd,
                    children: [
                      UserAvatar(
                        name: '${foundPerson.firstName} ${foundPerson.lastName}'
                            .trim(),
                        photoUrl: foundPerson.profilePhoto,
                        radius: AppSize.tile / 2,
                        backgroundColor: AppColors.primary(context),
                        textColor: AppColors.onPrimary(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppSpacing.xs,
                          children: [
                            Text(
                              '${foundPerson.firstName} ${foundPerson.lastName}'
                                  .trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.sectionWithColor(
                                context,
                                color: AppColors.onPrimaryContainer(context),
                              ),
                            ),
                            if (foundPerson.mobile != null)
                              Text(
                                foundPerson.mobile!,
                                style: AppTextStyles.metaWithColor(
                                  context,
                                  color: AppColors.onPrimaryContainer(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: isProcessing ? null : _searchAgain,
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRelationship,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Relationship *',
                    prefixIcon: Icon(
                      AppIcons.relationship,
                      size: AppSize.icon,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  items: [
                    for (final t in _relationshipTypes)
                      DropdownMenuItem(value: t, child: Text(t)),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedRelationship = val);
                    }
                  },
                ),
                AppButton(
                  label: 'Confirm & Link',
                  onPressed: _confirmLink,
                  isLoading: isProcessing,
                ),
              ],
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Can't find them? ",
                    style: AppTextStyles.bodyWithColor(context),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: Material(
                          type: MaterialType.transparency,
                          borderRadius: AppRadius.smAll,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _navigateToCreateUser();
                            },
                            child: Text(
                              'Create a user',
                              style:
                                  AppTextStyles.bodyWithColor(
                                    context,
                                    color: AppColors.primary(context),
                                  ).copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary(context),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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

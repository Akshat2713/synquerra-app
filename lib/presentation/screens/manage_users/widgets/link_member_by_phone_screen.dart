import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/app_router.dart';
import '../../../blocs/manage_users/manage_users_bloc.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class LinkMemberByPhoneBottomSheet extends StatefulWidget {
  const LinkMemberByPhoneBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<ManageUsersBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  final List<String> _relationshipTypes = [
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
    context.read<ManageUsersBloc>().add(
      ManageUsersConfirmLinkRequested(_selectedRelationship),
    );
  }

  void _searchAgain() {
    context.read<ManageUsersBloc>().add(const ManageUsersClearFoundPerson());
  }

  void _navigateToCreateUser() {
    final bloc = context.read<ManageUsersBloc>();
    Navigator.pop(context);
    Navigator.pushNamed(context, AppRoutes.addMember, arguments: bloc);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocConsumer<ManageUsersBloc, ManageUsersState>(
      listenWhen: (prev, curr) =>
          curr is ManageUsersLoaded &&
          curr.foundPerson != null &&
          !curr.isProcessing &&
          prev is ManageUsersLoaded &&
          prev.isProcessing,
      listener: (context, state) {
        // Relationship successfully created -> foundPerson would be cleared
        // by the load-refresh cycle; if still present with no error, ignore.
      },
      builder: (context, state) {
        final loaded = state is ManageUsersLoaded ? state : null;
        final isSearching = loaded?.isSearching ?? false;
        final isProcessing = loaded?.isProcessing ?? false;
        final foundPerson = loaded?.foundPerson;
        final errorMessage = loaded?.errorMessage;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary(
                        context,
                      ).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Link Member',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      visualDensity: VisualDensity.compact,
                      color: AppColors.textSecondary(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter the registered phone number of the member you want to link.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone search step — locked once a person is found
                Form(
                  key: _phoneFormKey,
                  child: AppTextField(
                    controller: _phoneController,
                    label: 'Phone Number *',
                    hint: '+917878787878',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    enabled: foundPerson == null,
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

                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ],

                const SizedBox(height: 16),

                if (foundPerson == null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: isSearching ? 'Searching...' : 'Search',
                      onPressed: isSearching ? null : _search,
                    ),
                  ),
                ] else ...[
                  // Found person card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      border: Border.all(
                        color: AppColors.outlineVariant(context),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          backgroundImage: foundPerson.profilePhoto != null
                              ? NetworkImage(foundPerson.profilePhoto!)
                              : null,
                          child: foundPerson.profilePhoto == null
                              ? Text(
                                  foundPerson.firstName.isNotEmpty
                                      ? foundPerson.firstName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(color: AppColors.primary),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${foundPerson.firstName} ${foundPerson.lastName}'
                                    .trim(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              if (foundPerson.mobile != null)
                                Text(
                                  foundPerson.mobile!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary(context),
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
                  const SizedBox(height: 16),

                  Text(
                    'Relationship *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRelationship,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.outlineVariant(context),
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.diversity_3_outlined,
                        color: AppColors.textSecondary(context),
                        size: 20,
                      ),
                    ),
                    items: _relationshipTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRelationship = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: isProcessing ? 'Linking...' : 'Confirm & Link',
                      onPressed: isProcessing ? null : _confirmLink,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Can't find them? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                      children: [
                        TextSpan(
                          text: 'Create a user',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _navigateToCreateUser,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_router.dart';
import '../../blocs/signup/signup_bloc.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/signup_progress_tracker.dart';

class LinkDeviceScreen extends StatefulWidget {
  const LinkDeviceScreen({super.key});

  @override
  State<LinkDeviceScreen> createState() => _LinkDeviceScreenState();
}

String _ownerType = 'person';

class _LinkDeviceScreenState extends State<LinkDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();

  @override
  void dispose() {
    _serialNumberController.dispose();
    super.dispose();
  }

  // void _submit() {
  //   if (!_formKey.currentState!.validate()) return;
  //   context.read<SignupBloc>().add(
  //     SignupDeviceLinked(
  //       ownerType: _ownerType,
  //       deviceSerialNo: _serialNumberController.text.trim(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        // Signup fully complete → navigate to login, clear entire stack
        if (state.status == SignupStatus.done) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text(
                  'Account created successfully! Please sign in.',
                ),
                backgroundColor: colors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }

        // Show error snackbar
        if (state.status == SignupStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: colors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Page Header ──────────────────────────────
                  Text(
                    'Link Your Device',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connect your Synquerra hardware device to your profile to start monitoring.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Progress Tracker ─────────────────────────
                  const SignupProgressTracker(currentStep: SignupStep.device),
                  const SizedBox(height: 48),

                  // ── Device Icon ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.router_rounded,
                      size: 64,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Owner Type Dropdown ───────────────────────
                  DropdownButtonFormField<String>(
                    value: _ownerType,
                    decoration: const InputDecoration(
                      labelText: 'Owner *',
                      prefixIcon: Icon(Icons.person_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'person', child: Text('Person')),
                      DropdownMenuItem(
                        value: 'organization',
                        child: Text('Organization'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _ownerType = val);
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Serial Number Field ───────────────────────
                  AppTextField(
                    controller: _serialNumberController,
                    label: 'Device Serial Number *',
                    hint: 'sqP4YT8TR',
                    prefixIcon: Icons.fingerprint_rounded,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {},
                    // _submit(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Serial number is required to finish setup.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'You can find the unique serial number printed on the back of your smart card tracker or on its packaging box.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Footer ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.read<SignupBloc>().add(
                            const SignupStepBack(),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                      // ── Right side: Skip + Complete ──────────
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // TODO: navigate to landing screen
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route) => false,
                              );
                            },
                            child: Text(
                              'Skip',
                              style: TextStyle(color: colors.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(width: 8),
                          BlocBuilder<SignupBloc, SignupState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: 160,
                                child: AppButton(
                                  label: 'Complete Setup',
                                  onPressed: null,
                                  // _submit,
                                  isLoading:
                                      state.status == SignupStatus.loading,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// lib/presentation/screens/profile/feedback_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/feedback/satisfaction_emoji_selector.dart';
import '../../widgets/feedback/follow_up_radio_group.dart';
import '../../widgets/buttons/loading_button.dart';
import '../../widgets/feedback/custom_snackbar.dart';
import '../../themes/colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

// enum FollowUpPermission { yes, no, none }

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedSatisfaction = -1;
  FollowUpPermission _followUp = FollowUpPermission.none;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_selectedSatisfaction == -1) {
      CustomSnackbar.show(
        context,
        message: 'Please select your satisfaction level.',
        type: SnackbarType.error,
      );
      return;
    }
    if (_followUp == FollowUpPermission.none) {
      CustomSnackbar.show(
        context,
        message: 'Please indicate if we may follow up.',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        CustomSnackbar.show(
          context,
          message: 'Thank you for your feedback!',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Feedback")),
      backgroundColor: isDarkMode
          ? const Color(0xff1a1a1a)
          : theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help us improve!",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "How satisfied are you with using Synquerra?",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 25),

            SatisfactionEmojiSelector(
              selectedIndex: _selectedSatisfaction,
              onSelected: (index) =>
                  setState(() => _selectedSatisfaction = index),
            ),
            const SizedBox(height: 35),

            Text(
              "Do you have any thoughts you would like to share?",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Please share your experience...",
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 35),

            Text(
              "May we follow you up on your feedback?",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 15),
            FollowUpRadioGroup(
              value: _followUp,
              onChanged: (value) => setState(() => _followUp = value),
            ),
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerRight,
              child: LoadingButton(
                onPressed: _submitFeedback,
                isLoading: _isSubmitting,
                label: "Submit",
                backgroundColor: Colors.green,
                fullWidth: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

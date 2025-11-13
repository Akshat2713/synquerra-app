import 'package:flutter/material.dart';
import 'package:safe_track/theme/colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

// Enum for clarity in radio button state
enum FollowUpPermission { yes, no, none }

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedSatisfaction = -1; // -1 means none selected, 0-4 for emojis
  FollowUpPermission _followUp =
      FollowUpPermission.none; // Track radio button state
  final TextEditingController _feedbackController = TextEditingController();

  // List of emojis representing satisfaction levels
  final List<String> _satisfactionEmojis = ['😞', '😟', '😐', '😊', '😄'];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    // Basic validation
    if (_selectedSatisfaction == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your satisfaction level.')),
      );
      return;
    }
    if (_followUp == FollowUpPermission.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please indicate if we may follow up.')),
      );
      return;
    }

    // --- TODO: Implement actual feedback submission logic here ---
    print('Satisfaction: ${_selectedSatisfaction + 1}'); // 1 to 5 scale
    print('Feedback Text: ${_feedbackController.text}');
    print('Allow Follow Up: ${_followUp == FollowUpPermission.yes}');

    // Show a confirmation message (optional)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your feedback!')),
    );

    // Optionally navigate back or reset the form
    // Navigator.pop(context);
    setState(() {
      _selectedSatisfaction = -1;
      _feedbackController.clear();
      _followUp = FollowUpPermission.none;
    });
    // --- End of submission logic ---
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Assuming a dark theme context based on the image
    // You might want to adjust colors based on Brightness.light if needed
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDarkMode
        ? Colors.grey[400]!
        : Colors.grey[700]!;
    final Color borderColor = isDarkMode
        ? Colors.grey[700]!
        : Colors.grey[400]!;
    final Color cardBackgroundColor = isDarkMode
        ? Colors.grey[850]!
        : Colors.white; // Or use colorScheme.surface

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        // backgroundColor: isDarkMode ? Colors.grey[900] : theme.primaryColor, // Example AppBar color
      ),
      // Use a background color similar to the image if the default scaffold color differs
      backgroundColor: isDarkMode
          ? const Color(0xff1a1a1a)
          : theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        // Allows scrolling if content overflows
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Help us improve!",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "How satisfied are you with using Synquerra?", // Assuming app name
              style: theme.textTheme.titleMedium?.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 25),

            // --- Satisfaction Emojis ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_satisfactionEmojis.length, (index) {
                bool isSelected = _selectedSatisfaction == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSatisfaction = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.safeGreen.withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : borderColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _satisfactionEmojis[index],
                      style: const TextStyle(fontSize: 32), // Adjust emoji size
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 35),

            // --- Feedback Text Field ---
            Text(
              "Do you have any thoughts you would like to share?",
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _feedbackController,
              maxLines: 5, // Allow multiple lines
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Please share your experience...",
                hintStyle: TextStyle(
                  color: secondaryTextColor.withOpacity(0.7),
                ),
                filled: true,
                fillColor: cardBackgroundColor, // Match card background
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ), // Highlight when focused
                ),
              ),
            ),
            const SizedBox(height: 35),

            // --- Follow Up Permission ---
            Text(
              "May we follow you up on your feedback?",
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Radio<FollowUpPermission>(
                  value: FollowUpPermission.yes,
                  groupValue: _followUp,
                  onChanged: (FollowUpPermission? value) {
                    setState(() {
                      _followUp = value!;
                    });
                  },
                  activeColor: colorScheme.primary, // Color when selected
                  // fillColor: MaterialStateProperty.resolveWith<Color>((states) { // Customize colors further if needed
                  //   if (states.contains(MaterialState.selected)) return colorScheme.primary;
                  //   return secondaryTextColor;
                  // }),
                ),
                Text('Yes', style: TextStyle(color: textColor, fontSize: 16)),
                const SizedBox(width: 20),
                Radio<FollowUpPermission>(
                  value: FollowUpPermission.no,
                  groupValue: _followUp,
                  onChanged: (FollowUpPermission? value) {
                    setState(() {
                      _followUp = value!;
                    });
                  },
                  activeColor: colorScheme.primary,
                ),
                Text('No', style: TextStyle(color: textColor, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 40),

            // --- Submit Button ---
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Green background
                  foregroundColor: Colors.white, // White text
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
                ),
                onPressed: _submitFeedback,
                child: const Text("Submit"),
              ),
            ),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}

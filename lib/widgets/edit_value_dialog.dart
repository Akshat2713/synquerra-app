import 'package:flutter/material.dart';

class EditValueDialog extends StatefulWidget {
  final String title;
  final String initialValue;
  final Function(String) onSave; // Callback to return the new value
  final TextInputType keyboardType; // To control keyboard (e.g., numbers)
  final String? valueSuffix; // Optional suffix like 'km/hr' or '°C'

  const EditValueDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
    this.keyboardType = TextInputType.text, // Default to text input
    this.valueSuffix,
  });

  @override
  State<EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<EditValueDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller, removing suffix if present
    String initialEditableValue = widget.initialValue;
    if (widget.valueSuffix != null &&
        widget.initialValue.endsWith(widget.valueSuffix!)) {
      initialEditableValue = widget.initialValue
          .substring(0, widget.initialValue.length - widget.valueSuffix!.length)
          .trim();
    }
    _controller = TextEditingController(text: initialEditableValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface, // Use surface for background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Text(widget.title, style: TextStyle(color: colorScheme.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Make column height fit content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current value: ${widget.initialValue}',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter new value',
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              suffixText: widget.valueSuffix, // Show suffix in the text field
              suffixStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 10.0,
              ),
            ),
            autofocus: true, // Automatically focus the text field
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Green save button
            foregroundColor: Colors.white, // White text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Save'),
          onPressed: () {
            // Add suffix back before saving if needed
            String newValue = _controller.text;
            if (widget.valueSuffix != null &&
                !newValue.endsWith(widget.valueSuffix!)) {
              newValue = '$newValue${widget.valueSuffix!}'
                  .trim(); // Re-attach suffix
            }
            widget.onSave(newValue); // Call the save callback
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ],
    );
  }
}

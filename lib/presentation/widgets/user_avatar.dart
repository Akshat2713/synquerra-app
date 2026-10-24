import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../themes/colors.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? photoUrl;
  final double radius;
  final int maxInitials;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.radius = 20,
    this.maxInitials = 2,
    this.backgroundColor,
    this.textColor,
  });

  /// "John Doe" -> "JD", "john" -> "J", "" / null -> ""
  static String initialsOf(String? name, {int max = 2}) {
    if (name == null) return '';
    final buffer = StringBuffer();
    for (final word in name.trim().split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      buffer.write(String.fromCharCode(word.runes.first).toUpperCase());
      if (buffer.length >= max) break;
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final initials = initialsOf(name, max: maxInitials);
    final fg = textColor ?? AppColors.onPrimaryContainer(context);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primaryContainer(context),
      // foregroundImage draws over the child; if it fails/is loading,
      // the initials underneath stay visible.
      foregroundImage: hasPhoto ? CachedNetworkImageProvider(photoUrl!) : null,
      // onForegroundImageError: hasPhoto ? (_, __) {} : null,
      child: initials.isEmpty
          ? Icon(Icons.person, size: radius * 1.1, color: fg)
          : Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
    );
  }
}

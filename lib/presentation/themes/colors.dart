import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // ==========================================
  // ===== BRAND / ACCENT (SEMANTIC) ==========
  // ==========================================
  // Primary CTA buttons, active tab indicators, selected chip borders ("Live", "Sync", "+ Device")
  static const Color primary = Color(0xFFA855F7);
  static const Color primaryHover = Color(0xFF9333EA);
  static const Color primarySubtle = Color(0xFFC084FC);

  // Soft container background for active icons & subtle badges
  static const Color primaryContainer = Color(0x1FA855F7);
  static const Color primaryBorder = Color(0x66A855F7);

  // ==========================================
  // ===== STATUS / FEEDBACK ==================
  // ==========================================
  // Success (Safe, GPS Restored, Normal battery)
  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0x1F22C55E); // "Safe" badge fill
  static const Color onSuccess = Colors.white;

  // Warning (Needs attention, Fair signal, GPS Lost)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(
    0x1FF59E0B,
  ); // "Needs attention" badge fill
  static const Color onWarning = Colors.white;

  // Danger / Error (SOS alert pressed, battery critical)
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerContainer = Color(0x1FEF4444); // SOS item fill
  static const Color onDanger = Colors.white;

  // Info / Live tracking indicator
  static const Color info = Color(0xFF38BDF8);
  static const Color infoContainer = Color(0x1F38BDF8);

  // ==========================================
  // ===== LIGHT THEME TOKENS =================
  // ==========================================
  // Surfaces & Backgrounds
  static const Color lightBackground = Color(
    0xFFF7F7FA,
  ); // Main page/scaffold background
  static const Color lightSurface = Color(
    0xFFFFFFFF,
  ); // Cards, bottom navigation, modals
  static const Color lightSurfaceVariant = Color(
    0xFFF3F3F8,
  ); // Input fields, unselected chips, inner rows

  // Borders & Dividers
  static const Color lightOutline = Color(
    0xFFE8E8EE,
  ); // Card borders, textfield strokes
  static const Color lightOutlineVariant = Color(
    0xFFF0F0F4,
  ); // Inner item dividers, subtle separators

  // Typography
  static const Color lightTextPrimary = Color(
    0xFF0F172A,
  ); // Main titles, bold values, card headings
  static const Color lightTextSecondary = Color(
    0xFF64748B,
  ); // Subtitles, descriptions, active chip text
  static const Color lightTextTertiary = Color(
    0xFF94A3B8,
  ); // Timestamps, inactive labels, metrics captions
  static const Color lightTextDisabled = Color(
    0xFFCBD5E1,
  ); // Disabled button/text state

  // Icons
  static const Color lightIconPrimary = Color(
    0xFF1E293B,
  ); // Standalone action icons
  static const Color lightIconSecondary = Color(
    0xFF94A3B8,
  ); // Chevrons, unselected nav icons

  // ==========================================
  // ===== DARK THEME TOKENS ==================
  // ==========================================
  // Surfaces & Backgrounds
  static const Color darkBackground = Color(
    0xFF0B0A13,
  ); // Main page/scaffold background
  static const Color darkSurface = Color(
    0xFF151421,
  ); // Cards, bottom navigation, modals
  static const Color darkSurfaceVariant = Color(
    0xFF1D1C2B,
  ); // Input fields, dropdowns, unselected chips

  // Borders & Dividers
  static const Color darkOutline = Color(
    0xFF272538,
  ); // Card borders, textfield strokes
  static const Color darkOutlineVariant = Color(
    0xFF1E1D2D,
  ); // Inner item dividers, subtle separators

  // Typography
  static const Color darkTextPrimary = Color(
    0xFFF8FAFC,
  ); // Main titles, bold values, card headings
  static const Color darkTextSecondary = Color(
    0xFFCBD5E1,
  ); // Subtitles, descriptions, active chip text
  static const Color darkTextTertiary = Color(
    0xFF64748B,
  ); // Timestamps, inactive labels, metrics captions
  static const Color darkTextDisabled = Color(
    0xFF475569,
  ); // Disabled button/text state

  // Icons
  static const Color darkIconPrimary = Color(
    0xFFF8FAFC,
  ); // Standalone action icons
  static const Color darkIconSecondary = Color(
    0xFF64748B,
  ); // Chevrons, unselected nav icons

  // ==========================================
  // ===== MAP / SPECIAL ENVIRONMENT TOKENS ===
  // ==========================================
  // Custom tag/zone categories
  static const Color environmentCategory1 = Color(
    0xFFF59E0B,
  ); // "Home" geofence ring & badge
  static const Color environmentCategory2 = Color(
    0xFFA855F7,
  ); // "Work" geofence ring & badge
  static const Color environmentCategory3 = Color(
    0xFF10B981,
  ); // "Safe" geofence ring & badge

  // Map elements (Light Mode)
  static const Color lightMapPath = Color(0xFFFFFFFF);
  static const Color lightMapZonePrimary = Color(0xFFD1FAE5);
  static const Color lightMapZoneSecondary = Color(0xFFDBEAFE);

  // Map elements (Dark Mode)
  static const Color darkMapPath = Color(0xFF1E1D2D);
  static const Color darkMapZonePrimary = Color(0xFF064E3B);
  static const Color darkMapZoneSecondary = Color(0xFF1E3A8A);

  // ==========================================
  // ===== GRADIENTS ==========================
  // ==========================================
  // Primary CTA buttons ("+ Device", "Sync", "Add")
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC026D3), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==========================================
  // ===== SHADOWS (missing, theme.dart needs these) =====
  // ==========================================
  static const Color lightShadow = Color(
    0x14000000,
  ); // 8% black — card elevation
  static const Color lightScrim = Color(
    0x52000000,
  ); // 32% black — modal/dialog backdrop
  static const Color darkShadow = Color(
    0x33000000,
  ); // 20% black — card elevation
  static const Color darkScrim = Color(
    0x80000000,
  ); // 50% black — modal/dialog backdrop
}

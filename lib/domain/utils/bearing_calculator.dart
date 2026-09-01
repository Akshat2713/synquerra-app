// lib/domain/utils/bearing_calculator.dart
import 'dart:math' as math;

/// Calculates initial compass bearing (0–360°, 0 = North) from one
/// coordinate to another. Pure math — no Flutter/map dependencies.
class BearingCalculator {
  const BearingCalculator._();

  static double calculate({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final startLatRad = _toRadians(startLat);
    final endLatRad = _toRadians(endLat);
    final deltaLngRad = _toRadians(endLng - startLng);

    final y = math.sin(deltaLngRad) * math.cos(endLatRad);
    final x =
        math.cos(startLatRad) * math.sin(endLatRad) -
        math.sin(startLatRad) * math.cos(endLatRad) * math.cos(deltaLngRad);

    final bearingRad = math.atan2(y, x);
    final bearingDeg = _toDegrees(bearingRad);
    return (bearingDeg + 360) % 360;
  }

  static double _toRadians(double degree) => degree * math.pi / 180;
  static double _toDegrees(double radian) => radian * 180 / math.pi;
}

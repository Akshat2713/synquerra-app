import 'dart:ui';

/// Shared math so the curved line and the arrow markers always agree.
class CurveGeometry {
  CurveGeometry._();

  /// Segments shorter than this (in px) are treated as duplicates.
  static const minSegment = 0.5;

  /// Unit tangent from the neighbors. Falls back to the segment direction
  /// if the neighbors point the opposite way (sharp reversal), which
  /// prevents loops.
  static Offset unitDir(Offset tangent, Offset seg) {
    final s = seg / seg.distance;
    final tLen = tangent.distance;
    if (tLen < 1e-6) return s;
    final t = tangent / tLen;
    return (t.dx * s.dx + t.dy * s.dy) < 0 ? s : t;
  }

  /// Direction the curve leaves point [i] toward point i+1, as a unit vector.
  /// Returns null if the segment is a duplicate (the painter skips it too).
  static Offset? tangentAt(List<Offset> pts, int i) {
    if (i < 0 || i >= pts.length - 1) return null;
    final p0 = i == 0 ? pts[i] : pts[i - 1];
    final p1 = pts[i];
    final p2 = pts[i + 1];
    final seg = p2 - p1;
    if (seg.distance < minSegment) return null;
    return unitDir(p2 - p0, seg);
  }
}

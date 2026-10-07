import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng; // avoids the Path clash

import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../themes/colors.dart';
import 'utils/curve_geometry.dart';

class MapHistoryPolylineLayer extends StatelessWidget {
  const MapHistoryPolylineLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (prev, curr) {
        if (prev is AnalyticsLoaded && curr is AnalyticsLoaded) {
          return prev.points != curr.points;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        final loaded = state is AnalyticsLoaded ? state : null;
        if (loaded == null || loaded.mappablePoints.length < 2) {
          return const SizedBox.shrink();
        }
        return _CurvedPolyline(
          points: loaded.mappablePoints
              .map((p) => LatLng(p.latitude!, p.longitude!))
              .toList(),
          color: AppColors.primarySubtle(context),
          borderColor: AppColors.darkMapPath,
        );
      },
    );
  }
}

class _CurvedPolyline extends StatelessWidget {
  const _CurvedPolyline({
    required this.points,
    required this.color,
    required this.borderColor,
  });

  final List<LatLng> points;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context); // subscribes to pan/zoom/rotation
    final offsets = points.map(camera.latLngToScreenOffset).toList();

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _CurvePainter(
          pts: offsets,
          color: color,
          borderColor: borderColor,
        ),
      ),
    );
  }
}

class _CurvePainter extends CustomPainter {
  _CurvePainter({
    required this.pts,
    required this.color,
    required this.borderColor,
  });

  final List<Offset> pts;
  final Color color;
  final Color borderColor;

  static const _width = 3.0;
  static const _borderWidth = 1.0;
  static const _dashOn = 10.0;
  static const _dashOff = 12.0;

  /// Handle length as a fraction of each segment's own length.
  /// 0 = straight, 0.25 = balanced, 0.35+ = exaggerated.
  static const _handleFactor = 0.32;

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 2) return;

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 0; i < pts.length - 1; i++) {
      final p0 = i == 0 ? pts[i] : pts[i - 1];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];

      final seg = p2 - p1;
      final segLen = seg.distance;
      if (segLen < CurveGeometry.minSegment) continue; // duplicate point

      // Handle length depends only on this segment, so short segments
      // can only bow slightly and never swing off the route.
      final handle = segLen * _handleFactor;
      final c1 = p1 + CurveGeometry.unitDir(p2 - p0, seg) * handle;
      final c2 = p2 - CurveGeometry.unitDir(p3 - p1, seg) * handle;

      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    final dashed = _dashed(path);

    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Border first (wider), then the main line on top.
    canvas.drawPath(dashed, stroke(borderColor, _width + _borderWidth * 2));
    canvas.drawPath(dashed, stroke(color, _width));
  }

  Path _dashed(Path source) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        out.addPath(metric.extractPath(d, d + _dashOn), Offset.zero);
        d += _dashOn + _dashOff;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_CurvePainter old) =>
      old.pts != pts || old.color != color || old.borderColor != borderColor;
}

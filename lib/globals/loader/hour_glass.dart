import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class SpinKitHourGlass extends StatefulWidget {
  final Color color;
  final double size;

  const SpinKitHourGlass({
    required Key key,
    required this.color,
    this.size = 50.0,
  }) : super(key: key);

  @override
  State<SpinKitHourGlass> createState() => _SpinKitHourGlassState();
}

class _SpinKitHourGlassState extends State<SpinKitHourGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _animation1 = Tween(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    )..addListener(() => setState(() => <String, void>{}));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = Matrix4.identity()
      ..rotateZ((_animation1.value) * math.pi);
    return Center(
      child: Transform(
        transform: transform,
        alignment: FractionalOffset.center,
        child: CustomPaint(
          painter: _HourGlassPainter(color: widget.color),
          child: SizedBox(
            height: widget.size,
            width: widget.size,
          ),
        ),
      ),
    );
  }
}

class _HourGlassPainter extends CustomPainter {
  Paint p = Paint();
  double weight = 90.0;

  _HourGlassPainter({required Color color}) {
    p.color = color;
    p.strokeWidth = 1.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      0.0,
      getRadian(weight),
      true,
      p,
    );
    canvas.drawArc(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      getRadian(180.0),
      getRadian(weight),
      true,
      p,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) {
    return math.pi / 180 * angle;
  }
}

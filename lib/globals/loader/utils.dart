import 'dart:math' as math show sin, pi;

import 'package:flutter/widgets.dart';

class DelayTween extends Tween<double> {
  final double delay;

  DelayTween({
    required double begin,
    required double end,
    required this.delay,
  }) : super(begin: begin, end: end);

  @override
  double lerp(double t) {
    return super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);
  }

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class AngleDelayTween extends Tween<double> {
  final double delay;

  AngleDelayTween({
    required double begin,
    required double end,
    required this.delay,
  }) : super(begin: begin, end: end);

  @override
  double lerp(double t) => super.lerp(math.sin((t - delay) * math.pi * 0.5));

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

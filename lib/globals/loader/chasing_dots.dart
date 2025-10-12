import 'package:flutter/material.dart';

class SpinKitChasingDots extends StatefulWidget {
  final Color color;
  final double size;

  const SpinKitChasingDots({
    required Key key,
    required this.color,
    this.size = 50.0,
  }) : super(key: key);

  @override
  State<SpinKitChasingDots> createState() => _SpinKitChasingDotsState();
}

class _SpinKitChasingDotsState extends State<SpinKitChasingDots>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl, _rotateCtrl;
  late Animation<double> _scale, _rotate;
  final _duration = const Duration(milliseconds: 2000);

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: _duration);
    _rotateCtrl = AnimationController(vsync: this, duration: _duration);

    _scale = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    )
      ..addListener(() => setState(() => <String, void>{}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scaleCtrl.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _scaleCtrl.forward();
        }
      });

    _rotate = Tween(begin: 0.0, end: 360.0).animate(
      CurvedAnimation(parent: _rotateCtrl, curve: Curves.linear),
    )..addListener(() => setState(() => <String, void>{}));

    _rotateCtrl.repeat();
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.fromSize(
        size: Size.square(widget.size),
        child: Transform.rotate(
          angle: _rotate.value * 0.0174533,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0.0,
                child: _circle(1.0 - _scale.value.abs()),
              ),
              Positioned(
                bottom: 0.0,
                child: _circle(_scale.value.abs()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double scale) {
    final size = widget.size * 0.6;

    return Transform.scale(
      scale: scale,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:back_packers/globals/loader/utils.dart';

class SpinKitThreeBounce extends StatefulWidget {
  final Color color;
  final double size;

  const SpinKitThreeBounce({
    Key? key,
    required this.color,
    this.size = 50.0,
  }) : super(key: key);

  @override
  State<SpinKitThreeBounce> createState() => _SpinKitThreeBounceState();
}

class _SpinKitThreeBounceState extends State<SpinKitThreeBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  final _duration = const Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: _duration,
    )..repeat();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(widget.size * 2, widget.size),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _circle(.0),
          _circle(.2),
          _circle(.4),
        ],
      ),
    );
  }

  Widget _circle(double delay) {
    final size = widget.size * 0.5;
    return ScaleTransition(
      scale: DelayTween(begin: 0.0, end: 1.0, delay: delay).animate(_scaleCtrl),
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

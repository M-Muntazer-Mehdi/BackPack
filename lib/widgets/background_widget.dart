import 'package:flutter/material.dart';
import 'package:back_packers/utils/app_colors.dart';

class BackGroundWidget extends StatelessWidget {
  final double height;
  const BackGroundWidget({Key? key, this.height = 2.2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      height: double.infinity,
      width: double.infinity,
      child: ClipPath(
        clipper: ClipPathClass(),
        child: Container(
          height: MediaQuery.of(context).size.height / height + 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  HexColor('#090684'),
                  HexColor('#312DE5').withOpacity(0.84)
                ]),
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

class ClipPathClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MainBg extends StatelessWidget {
  final Widget child;
  final whiteBackground;
  const MainBg({super.key, required this.child, this.whiteBackground = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            top: -170,
            right: -170,
            child: Image.asset(
              'assets/images/ic_rings_top.png',
              color: whiteBackground
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : null,
            )),
        Positioned(
            bottom: -170,
            left: -170,
            child: Image.asset(
              'assets/images/ic_rings_bottom.png',
              color: whiteBackground
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : null,
            )),
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              color: whiteBackground
                  ? const Color.fromRGBO(255, 255, 255, 1)
                  : null,
              gradient: whiteBackground
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                          HexColor('#3531F1'),
                          HexColor('#221ED7').withOpacity(0.92),
                          HexColor('#1C19B3'),
                          HexColor('#090684')
                        ])),
          child: child,
        ),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}

class RadiantGradientMask extends StatelessWidget {
  const RadiantGradientMask({Key? key, required this.child, this.colors})
      : super(key: key);
  final Widget child;
  final List<Color>? colors;
  final defaultColors = const [
    Color(0xFF4400D5),
    Color(0xFFAA76FF),
    Color(0xFF4400D5),
    Color(0xFFAA76FF),
  ];

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: colors != null ? colors! : defaultColors,
        tileMode: TileMode.repeated,
      ).createShader(bounds),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
        child: child,
      ),
    );
  }
}

class PointPainter extends CustomPainter {
  PointPainter(this.color, [this.sizePoint = 10]);
  final Color color;
  final double sizePoint;
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = sizePoint;
    //draw points on canvas
    canvas.drawPoints(PointMode.points, [const Offset(5, 0)], paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

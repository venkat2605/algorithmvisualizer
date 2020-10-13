import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BarPainter extends CustomPainter {
  final double width;
  final int value;
  final int index;
  final int samplesize;

  BarPainter({this.width, this.value, this.index, this.samplesize});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    if (this.value < samplesize * .10) {
      paint.color = Colors.red[50];
    } else if (this.value < samplesize * .20) {
      paint.color = Colors.red[100];
    } else if (this.value < samplesize * .30) {
      paint.color = Colors.red[200];
    } else if (this.value < samplesize * .40) {
      paint.color = Colors.red[300];
    } else if (this.value < samplesize * .50) {
      paint.color = Colors.red[400];
    } else if (this.value < samplesize * .60) {
      paint.color = Colors.red;
    } else if (this.value < samplesize * .70) {
      paint.color = Colors.red[600];
    } else if (this.value < samplesize * .80) {
      paint.color = Colors.red[700];
    } else if (this.value < samplesize * .90) {
      paint.color = Colors.red[900];
    } else {
      paint.color = Colors.redAccent[700];
    }

    paint.strokeWidth = width;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(index * width, 0),
        Offset(index * width, value.ceilToDouble()), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

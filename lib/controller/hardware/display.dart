import 'dart:ui';

class Display{
  static double vw = 0;
  static double vh = 0;

  static void updateSize({Size size}) {
    vh = size.height/100;
    vw = size.width/100;
  }
}
import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Display{
  static double vw = 0;
  static double vh = 0;

  static void updateSize(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //print("display update");
    vh = size.height/100 ;
    vw = size.width/100;
  }

  static bool isLandscape(BuildContext context){
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}
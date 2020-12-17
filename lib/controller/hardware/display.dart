import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Display{
  static double vw = 0;
  static double vh = 0;
  static Display _instance;
  static BuildContext context;


  static void updateSize() {
    Size size = MediaQuery.of(context).size;
    double multiplier = MediaQuery.of(context).devicePixelRatio;
    //size = size / multiplier;
    print([multiplier, Display.calculate(Size(150, 80)), MediaQuery.of(context).size]);
    vh = size.height/100 ;
    vw = size.width/100;
  }

  ///Prende in input un size target valutato su uno schermo 1920x1080
  ///Ritorna il size corrispondente sulla dimensione dello schermo attuale
  ///
  static Size calculate(Size target, {bool preserveAspectRatio, bool isLandscape = true}){
    Size size = MediaQuery.of(context).size;
    Size ref = Size(1920,1080);
    if(!isLandscape)
      ref = Size(1080,1920);
    return Size((size.width * target.width) / ref.width, (size.height * target.height) / ref.height);
  }

  static getWidth(double percent){
    return vw * percent;
  }

  static getHeight(double percent){
    return vh * percent;
  }
}
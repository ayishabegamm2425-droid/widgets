// utils/size_config.dart
import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static final SizeConfig _instance = SizeConfig._internal();
  factory SizeConfig() => _instance;
  SizeConfig._internal();

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    
    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  static double getWidth(double width) => width * (screenWidth / 375.0);
  static double getHeight(double height) => height * (screenHeight / 812.0);
  static double getFont(double size) => size * (screenWidth / 375.0);
  static double getRelativeWidth(double percent) => screenWidth * percent;
  static double getRelativeHeight(double percent) => screenHeight * percent;
}

// import 'dart:math';

// import 'package:flutter/material.dart';

// class SizeConfig {
//   static late MediaQueryData _mediaQueryData;
//   static late double screenWidth;
//   static late double screenHeight;
//   static late double blockSizeHorizontal;
//   static late double blockSizeVertical;
  
//   // Safe area measurements
//   static late double _safeAreaHorizontal;
//   static late double _safeAreaVertical;
//   static late double safeBlockHorizontal;
//   static late double safeBlockVertical;
  
//   // Reference device dimensions (iPhone 13 dimensions)
//   static const double _referenceWidth = 390.0; 
//   static const double _referenceHeight = 844.0;

//   static final SizeConfig _instance = SizeConfig._internal();
//   factory SizeConfig() => _instance;
//   SizeConfig._internal();

//   void init(BuildContext context) {
//     _mediaQueryData = MediaQuery.of(context);
//     screenWidth = _mediaQueryData.size.width;
//     screenHeight = _mediaQueryData.size.height;
    
//     // Calculate block sizes
//     blockSizeHorizontal = screenWidth / 100;
//     blockSizeVertical = screenHeight / 100;
    
//     // Calculate safe area
//     _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
//     _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
//     safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
//     safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
//   }

//   /// Scales the width based on the reference device width
//   static double scaleWidth(double width) => (width / _referenceWidth) * screenWidth;
  
//   /// Scales the height based on the reference device height
//   static double scaleHeight(double height) => (height / _referenceHeight) * screenHeight;
  
//   /// Scales the font size based on both width and height with a factor
//   static double scaleFont(double size, {double factor = 0.5}) {
//     double scale = min(screenWidth / _referenceWidth, screenHeight / _referenceHeight);
//     return size * scale * factor;
//   }
  
//   /// Gets percentage of screen width
//   static double widthPercent(double percent) => screenWidth * (percent / 100);
  
//   /// Gets percentage of screen height
//   static double heightPercent(double percent) => screenHeight * (percent / 100);
  
//   /// Gets percentage of the smallest dimension
//   static double sizePercent(double percent) => min(screenWidth, screenHeight) * (percent / 100);
  
//   /// Checks if the screen is in landscape mode
//   static bool get isLandscape => screenWidth > screenHeight;
  
//   /// Returns the smaller dimension (width or height)
//   static double get shorterSide => min(screenWidth, screenHeight);
  
//   /// Returns the longer dimension (width or height)
//   static double get longerSide => max(screenWidth, screenHeight);
// }
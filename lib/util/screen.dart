import 'package:flutter/material.dart';

bool checkFoldableDevice(BuildContext context) {
  MediaQueryData mediaQuery = MediaQuery.of(context);

  // 获取屏幕的宽度和高度
  double screenWidth = mediaQuery.size.width;
  double screenHeight = mediaQuery.size.height;

  // 获取屏幕的旋转方向
  final isLandscape = mediaQuery.orientation == Orientation.landscape;

  // 根据旋转方向调整宽度和高度
  double adjustedWidth = isLandscape ? screenHeight : screenWidth;
  double adjustedHeight = isLandscape ? screenWidth : screenHeight;

  // 计算屏幕横纵比
  double aspectRatio = adjustedWidth / adjustedHeight;
  return aspectRatio > 0.5;
}

bool checkIsTablet(BuildContext context) {
  MediaQueryData mediaQuery = MediaQuery.of(context);

  // 获取屏幕的宽度和高度
  double screenWidth = mediaQuery.size.width;
  double screenHeight = mediaQuery.size.height;
  print(screenWidth);
  print(screenHeight);
  if (screenWidth > 600 && screenHeight > 600) {
    return true;
  }
  return false;
}

double getHalfScreenLength(BuildContext context) {
  MediaQueryData mediaQuery = MediaQuery.of(context);

  // 获取屏幕的宽度和高度
  double screenWidth = mediaQuery.size.width;
  double screenHeight = mediaQuery.size.height;

  // 获取屏幕的旋转方向
  final isLandscape = mediaQuery.orientation == Orientation.landscape;

  // 根据旋转方向返回屏幕一半的长度
  return isLandscape ? screenHeight / 2 : screenWidth / 2;
}
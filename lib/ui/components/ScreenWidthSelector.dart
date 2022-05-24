import 'package:flutter/material.dart';

class ScreenWidthSelector extends StatelessWidget {
  final Widget verticalChild;
  final Widget? horizonChild;
  const ScreenWidthSelector({Key? key,required this.verticalChild,this.horizonChild}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 600;
    if (isWide) {
      return this.horizonChild ?? this.verticalChild;
    }
    return this.verticalChild;
  }
}

import 'package:chat/util/colors.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
          color: bubbleIndicator,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              width: 3,
              color: isLightTheme(context) ? Colors.white : Colors.black)),
    );
  }
}
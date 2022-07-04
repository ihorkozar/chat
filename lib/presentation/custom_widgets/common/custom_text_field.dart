import 'package:chat/util/colors.dart';
import 'package:chat/util/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final Function(String value) onChanged;
  final double height;
  final TextInputAction inputAction;

  const CustomTextField(
      {Key? key,
        this.height = 54.0,
        required this.hint,
        required this.onChanged,
        required this.inputAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: TextField(
          style: TextStyle(
              color: isLightTheme(context) ? Colors.black : Colors.white),
          keyboardType: TextInputType.text,
          onChanged: onChanged,
          textInputAction: inputAction,
          cursorColor: appColor,
          decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              hintText: hint,
              border: InputBorder.none)),
      decoration: BoxDecoration(
          color: isLightTheme(context) ? Colors.white : bubbleDark,
          borderRadius: BorderRadius.circular(45),
          border: Border.all(
              color:
              isLightTheme(context) ? const Color(0xFFC4C4C4) : const Color(0xFF393737),
              width: 1.5)),
    );
  }
}
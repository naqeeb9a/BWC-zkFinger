import 'package:fpzk/Widgets/custom_text.dart';
import 'package:fpzk/utils/utils.dart';
import 'package:flutter/material.dart';

import 'widget.dart';

class CustomButton extends StatelessWidget {
  final Color buttonColor;
  final String text;
  final Color textColor;
  final TextAlign? textAlign;
  final VoidCallback function;
  final int? maxLines;
  final double? height;
  final double? width;
  final bool invert;
  const CustomButton(
      {Key? key,
      required this.buttonColor,
      required this.text,
      this.textAlign,
      this.maxLines,
      this.textColor = Colors.black,
      required this.function,
      this.height,
      this.width,
      this.invert = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(15),
        width: width ?? MediaQuery.of(context).size.width * 0.7,
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: invert == true ? null : buttonColor,
            border: invert == true
                ? Border.all(width: 1, color: primaryColor)
                : null),
        child: CustomText(
          text: text,
          color: invert == true ? primaryColor : textColor,
          textAlign: textAlign,
          maxLines: maxLines,
        ),
      ),
    );
  }
}

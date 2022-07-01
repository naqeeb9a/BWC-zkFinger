import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoader extends StatelessWidget {
  final double width;
  const CustomLoader({Key? key, this.width = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: LottieBuilder.asset(
      "assets/loader.json",
      width: width,
    ));
  }
}

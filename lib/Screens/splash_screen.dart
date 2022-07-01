
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/app_routes.dart';
import 'Authentication/login.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Alignment _alignment = Alignment.bottomCenter;
  final Duration _duration = const Duration(seconds: 2);

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1))
        .then((value) => setState(() {
              _alignment = Alignment.center;
            }));
    Future.delayed(_duration * 1.2).then(
      (value) => KRoutes.pushAndRemoveUntil(context, const Login()),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            height: double.infinity,
            width: double.infinity,
            alignment: _alignment,
            duration: _duration,
            child: SvgPicture.asset(
              'assets/logo.svg',
              width: 200,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }
}

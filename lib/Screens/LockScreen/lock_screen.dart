// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:fpzk/Screens/home_screen.dart';
import 'package:fpzk/Widgets/custom_app_bar.dart';
import 'package:fpzk/utils/utils.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Provider/user_data_provider.dart';
import '../../Widgets/custom_button.dart';
import '../../utils/app_routes.dart';
import '../Authentication/login.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  String _authorized = 'Authenticate';
  bool _isAuthenticating = false;
  logout() {
    Provider.of<LoginInfoProvider>(context, listen: false)
        .changeLoginStatus(false);
    KRoutes.pushAndRemoveUntil(context, const Login());
  }

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => () async {
            if (!isSupported) {
              SharedPreferences user = await SharedPreferences.getInstance();
              user.clear();
              logout();
            }
          },
        );
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      CoolAlert.show(
          context: context,
          type: CoolAlertType.info,
          text: "Set a password on your phone from settings");
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
    if (_authorized == "Authorized") {
      KRoutes.pushAndRemoveUntil(context, const HomeScreen());
    }
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
          title: "Authentication",
          appBar: AppBar(),
          widgets: [
            IconButton(
                onPressed: () async {
                  SharedPreferences user =
                      await SharedPreferences.getInstance();
                  user.clear();
                  logout();
                },
                icon: const Icon(
                  Icons.login_outlined,
                  color: kblack,
                ))
          ],
          appBarHeight: 50),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LottieBuilder.asset(
            "assets/fp.json",
            repeat: false,
          ),
          if (_isAuthenticating)
            CustomButton(
                buttonColor: primaryColor,
                text: "Cancel Authentication",
                textColor: kWhite,
                function: () {
                  _cancelAuthentication();
                })
          else
            CustomButton(
                buttonColor: primaryColor,
                textColor: kWhite,
                text: _authorized,
                maxLines: 2,
                textAlign: TextAlign.center,
                function: () {
                  _authenticate();
                })
        ],
      ),
    );
  }
}

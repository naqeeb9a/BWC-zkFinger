import 'dart:convert';

import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fpzk/utils/app_routes.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Provider/user_data_provider.dart';
import '../Screens/DetailScreen/detail_screen.dart';
import '../Screens/LockScreen/lock_screen.dart';
import '../Widgets/widget.dart';
import '../utils/utils.dart';

class Functionality {
  static checkLoginStatus(
    context,
  ) async {
    SharedPreferences user = await SharedPreferences.getInstance();
    String? getUser = user.getString("loggedInUser");
    if (getUser != null) {
      var res = jsonDecode(getUser);
      Provider.of<UserDataProvider>(context, listen: false).updateUserData(res);
      KRoutes.pushAndRemoveUntil(context, const LockScreen());
    } else {
      Provider.of<LoginInfoProvider>(context, listen: false)
          .changeLoginStatus(false);
    }
  }

  static openDialogue(BuildContext context, TextEditingController controller) {
    String? societyId =
        Provider.of<SelectedSoceityProvider>(context, listen: false).id;
    pushScreen() {
      KRoutes.pop(context);
      KRoutes.push(
          context,
          DetailScreen(
            code: "reg_no=${controller.text}",
            id: societyId,
            isScan: false,
          ));
      controller.clear();
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LottieBuilder.asset(
                  "assets/write.json",
                  width: 200,
                  repeat: false,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(text: "Enter Registration Number")),
                ),
                const SizedBox(
                  height: 10,
                ),
                FormTextField(
                  controller: controller,
                  suffixIcon: const Icon(Icons.edit),
                  function: (value) {
                    if (value!.isEmpty) {
                      return "Field can't be Empty";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomButton(
                  text: "Get results",
                  textColor: kWhite,
                  function: () async {
                    bool canVibrate = await Vibrate.canVibrate;

                    if (canVibrate) {
                      var type = FeedbackType.light;
                      Vibrate.feedback(type);
                    }
                    if (controller.text.isEmpty) {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          text: "Field can't be empty",
                          backgroundColor: kblack,
                          lottieAsset: "assets/error.json");
                    } else {
                      pushScreen();
                    }
                  },
                  buttonColor: primaryColor,
                )
              ],
            ),
          );
        });
  }
}

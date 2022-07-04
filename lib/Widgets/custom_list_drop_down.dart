import 'dart:convert';

import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpzk/Widgets/custom_text.dart';
import 'package:fpzk/Widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api/api.dart';
import '../Provider/user_data_provider.dart';
import '../Screens/Authentication/login.dart';
import '../utils/app_routes.dart';
import 'custom_loader.dart';

class CustomDropDown extends StatefulWidget {
  final String token;
  const CustomDropDown({Key? key, required this.token}) : super(key: key);

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  String selectedCity = "Select";
  List societyList = [];
  bool isLoading = true;
  bool internet = true;
  getSocietyList(token) async {
    setState(() {
      isLoading = true;
    });

    try {
      Response response = await Api.getSocieties();

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        setState(() {
          societyList = jsonData["data"]["societies"];

          isLoading = false;
          internet = true;
        });
      } else if (response.statusCode == 501) {
        bool canVibrate = await Vibrate.canVibrate;

        if (canVibrate) {
          var type = FeedbackType.light;
          Vibrate.feedback(type);
        }
        SharedPreferences user = await SharedPreferences.getInstance();
        user.clear();
        logout();
        Fluttertoast.showToast(msg: "Token Expired, Please Login again");
      } else {
        setState(() {
          isLoading = false;
          internet = true;
        });
      }
    } on Exception {
      setState(() {
        isLoading = false;
        internet = false;
      });
    }
  }

  @override
  void initState() {
    getSocietyList(widget.token);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CustomLoader()
        : internet == false
            ? InkWell(
                onTap: () => getSocietyList(widget.token),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.rotate_90_degrees_ccw),
                    CustomText(text: "Retry")
                  ],
                ),
              )
            : DropdownButton(
                hint: CustomText(text: selectedCity),
                items: societyList
                    .map((dynamic value) => DropdownMenuItem(
                          value: value["title"] + "@" + value["id"].toString(),
                          child: CustomText(
                            text: value["title"],
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList(),
                onChanged: (dynamic value) {
                  setState(() {
                    selectedCity = value
                        .toString()
                        .substring(0, value.toString().indexOf('@'));
                    var id = value
                        .toString()
                        .substring(value.toString().indexOf("@") + 1);

                    Provider.of<SelectedSoceityProvider>(context, listen: false)
                        .updateSelectedSociety(value, id);
                  });
                },
                // ...
              );
  }

  logout() {
    Provider.of<LoginInfoProvider>(context, listen: false)
        .changeLoginStatus(false);
    KRoutes.pushAndRemoveUntil(context, const Login());
  }
}

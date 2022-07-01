import 'dart:convert';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fpzk/Provider/info_provider.dart';

import 'package:fpzk/Widgets/widget.dart';
import 'package:fpzk/utils/app_routes.dart';
import 'package:fpzk/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import "package:http/http.dart" as http;

import '../../Provider/user_data_provider.dart';

class ZKVerificationScreen extends StatefulWidget {
  final Map fingerMap;
  final dynamic convertedData;
  final dynamic fingerData;
  final bool isEnroll;
  const ZKVerificationScreen(
      {Key? key,
      required this.fingerMap,
      this.convertedData,
      this.fingerData,
      required this.isEnroll})
      : super(key: key);

  @override
  State<ZKVerificationScreen> createState() => _ZKVerificationScreenState();
}

class _ZKVerificationScreenState extends State<ZKVerificationScreen> {
  dynamic value;
  Uint8List? image;
  Stream fpData = const Stream.empty();
  getStreamFp() {
    fpData = eventChannel.receiveBroadcastStream().map((event) => event);
    return fpData;
  }

  final MethodChannel methodChannel =
      const MethodChannel("com.example.fpzk/method_channel");
  final EventChannel eventChannel =
      const EventChannel("com.example.fpzk/event_channel");
  int fingerIndex = 0;

  initializeFp() async {
    await methodChannel.invokeMethod("initialize_fingerprint_zk");

    verifyFp();
  }

  updateValue(res) {
    Provider.of<InfoProvider>(context, listen: false).updateMessage(res);
  }

  verifyFp() async {
    await methodChannel.invokeMethod("verify_fingerprint_zk", widget.fingerMap);
  }

  @override
  void initState() {
    initializeFp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserDataProvider>(context).userData;
    return Scaffold(
      appBar: BaseAppBar(
          title: "Verify Fingers",
          automaticallyImplyLeading: true,
          appBar: AppBar(),
          widgets: const [],
          appBarHeight: 50),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const CustomText(
                text: "Place a finger to verify",
                color: primaryColor,
                fontsize: 20,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(
                height: 50,
              ),
              StreamBuilder(
                stream: getStreamFp(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    image = base64Decode(snapshot.data["image"]
                        .toString()
                        .replaceAll("\n", "")
                        .replaceAll(" ", ""));

                    return Column(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(
                              image!,
                              height: 200,
                              width: 150,
                              fit: BoxFit.cover,
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        CustomText(
                            text: snapshot.data["message"].toString(),
                            fontWeight: FontWeight.bold,
                            fontsize: 30,
                            color: snapshot.data["message"].toString() ==
                                    "identify fail"
                                ? Colors.red
                                : Colors.green,
                            textAlign: TextAlign.center),
                      ],
                    );
                  } else {
                    return LottieBuilder.asset(
                      "assets/fpScanner.json",
                      width: 200,
                    );
                  }
                },
              ),
              const SizedBox(
                height: 30,
              ),
              CustomButton(
                  buttonColor: primaryColor,
                  text: "Initialize again",
                  textColor: kWhite,
                  function: () async {
                    bool canVibrate = await Vibrate.canVibrate;

                    if (canVibrate) {
                      var type = FeedbackType.light;
                      Vibrate.feedback(type);
                    }
                    await stopScanning();
                    await initializeFp();
                    setState(() {});
                  }),
              const SizedBox(
                height: 20,
              ),
              widget.isEnroll == false
                  ? Container()
                  : CustomButton(
                      buttonColor: primaryColor,
                      text: "Save fingerprint",
                      textColor: kWhite,
                      function: () async {
                        bool canVibrate = await Vibrate.canVibrate;

                        if (canVibrate) {
                          var type = FeedbackType.light;
                          Vibrate.feedback(type);
                        }
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.loading,
                            barrierDismissible: false);
                        var res = await http.post(
                            Uri.parse(
                                "http://167.99.236.246/bwc/frontend/web/api/scanner/save-thumb-member-data"),
                            headers: {
                              "last_login_token": userData["data"]["oauth"]
                                  ["access_token"],
                            },
                            body: {
                              "member_id": widget.convertedData["data"]
                                      ["verification"]["member_id"]
                                  .toString(),
                              "file_id": widget.convertedData["data"]
                                      ["verification"]["id"]
                                  .toString(),
                              "thumb_arr": jsonEncode({
                                "fingerprint1": [
                                  {
                                    "data": widget.fingerMap["saveFp1"],
                                    "img":
                                        widget.fingerData["finger1"]!["image3"]
                                  }
                                ],
                                "fingerprint2": [
                                  {
                                    "data": widget.fingerMap["saveFp2"],
                                    "img":
                                        widget.fingerData["finger2"]!["image3"]
                                  }
                                ],
                                "fingerprint3": [
                                  {
                                    "data": widget.fingerMap["saveFp3"],
                                    "img":
                                        widget.fingerData["finger3"]!["image3"]
                                  }
                                ],
                                "fingerprint4": [
                                  {
                                    "data": widget.fingerMap["saveFp4"],
                                    "img":
                                        widget.fingerData["finger4"]!["image3"]
                                  }
                                ],
                              })
                            });
                        if (res.statusCode == 200) {
                          popScreen();
                          popScreen();
                          popScreen();
                          Fluttertoast.showToast(msg: "Synced successfully");
                        } else {
                          popScreen();
                          Fluttertoast.showToast(msg: "Try again");
                        }
                      }),
            ],
          ),
        ),
      ),
    );
  }

  stopScanning() async {
    await methodChannel.invokeMethod("stop_fingerprint_zk");
  }

  popScreen() {
    KRoutes.pop(context);
  }

  @override
  void dispose() {
    eventChannel.receiveBroadcastStream().map((event) => null);
    stopScanning();
    super.dispose();
  }
}

import 'dart:convert';

import 'package:fpzk/Api/api.dart';
import 'package:fpzk/Provider/user_data_provider.dart';

import 'package:fpzk/Widgets/custom_loader.dart';
import 'package:fpzk/Widgets/images_grid.dart';
import 'package:fpzk/Widgets/widget.dart';
import 'package:fpzk/utils/app_routes.dart';
import 'package:fpzk/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../QRScreen/qr_screen.dart';

class DetailScreen extends StatelessWidget {
  final String? code, id;
  final bool isScan;

  const DetailScreen(
      {Key? key, required this.code, required this.id, required this.isScan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<UserDataProvider>(context).userData;
    var selectedSociety =
        Provider.of<SelectedSoceityProvider>(context).selectedSoceity;

    return Scaffold(
      appBar: BaseAppBar(
          title: "Verification Screen",
          appBar: AppBar(),
          automaticallyImplyLeading: true,
          widgets: const [],
          appBarHeight: 50),
      body: Center(
        child: FutureBuilder(
          future: Api.getSocietyInformation(
              code, id, userData["data"]["oauth"]["access_token"]),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null && snapshot.data.statusCode == 200) {
                final convertedData = jsonDecode(snapshot.data.body);

                return Padding(
                  padding: const EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Project name:",
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                            text: selectedSociety.toString().substring(
                                  0,
                                  selectedSociety.toString().indexOf('@'),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Registration number:",
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                            text: convertedData["data"]["verification"]
                                    ["reg_number"]
                                .toString(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Name:",
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                              text: convertedData["data"]["verification"]
                                      ["member_name"]
                                  .toString())
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Serial no:",
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                              text: convertedData["data"]["verification"]
                                      ["serial_no"]
                                  .toString())
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Form no:",
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                              text: convertedData["data"]["verification"]
                                      ["form_no"]
                                  .toString())
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Plot size:",
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                              text: convertedData["data"]["verification"]
                                      ["plot_size"]
                                  .toString())
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Security code :",
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                              text: convertedData["data"]["verification"]
                                      ["security_code"]
                                  .toString())
                        ],
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 5,
                      ),
                      const CustomText(
                        text: "Images",
                        fontsize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: ImageGrid(
                        convertedData: convertedData,
                        userData: userData,
                      )),
                    ],
                  ),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LottieBuilder.asset(
                      "assets/notVerified.json",
                      repeat: false,
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const CustomText(
                      text: "Sorry no data found",
                      fontsize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    CustomButton(
                        buttonColor: primaryColor,
                        text: "Next",
                        textColor: kWhite,
                        function: () {
                          KRoutes.pop(context);
                          if (isScan == true) {
                            KRoutes.push(context, const QRScreen());
                          }
                        })
                  ],
                );
              }
            } else {
              return const CustomLoader();
            }
          },
        ),
      ),
    );
  }
}

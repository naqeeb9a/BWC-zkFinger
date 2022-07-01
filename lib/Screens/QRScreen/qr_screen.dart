import 'package:fpzk/Provider/user_data_provider.dart';

import 'package:fpzk/Widgets/custom_app_bar.dart';
import 'package:fpzk/utils/app_routes.dart';
import 'package:fpzk/utils/utils.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../DetailScreen/detail_screen.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  MobileScannerController cameraController = MobileScannerController();
  @override
  Widget build(BuildContext context) {
    String? societyId = Provider.of<SelectedSoceityProvider>(context).id;
    return Scaffold(
        appBar: BaseAppBar(
            title: "Scan QR",
            appBar: AppBar(),
            automaticallyImplyLeading: true,
            widgets: [
              IconButton(
                color: kblack,
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.torchState,
                  builder: (context, state, child) {
                    switch (state as TorchState) {
                      case TorchState.off:
                        return const Icon(Icons.flash_off, color: Colors.grey);
                      case TorchState.on:
                        return const Icon(Icons.flash_on, color: Colors.yellow);
                    }
                  },
                ),
                onPressed: () => cameraController.toggleTorch(),
              ),
              IconButton(
                color: kblack,
                icon: ValueListenableBuilder(
                  valueListenable: cameraController.cameraFacingState,
                  builder: (context, state, child) {
                    switch (state as CameraFacing) {
                      case CameraFacing.front:
                        return const Icon(Icons.camera_front);
                      case CameraFacing.back:
                        return const Icon(Icons.camera_rear);
                    }
                  },
                ),
                onPressed: () => cameraController.switchCamera(),
              ),
            ],
            appBarHeight: 50),
        body: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 250,
              width: 250,
              child: MobileScanner(
                  allowDuplicates: false,
                  controller: cameraController,
                  onDetect: (barcode, args) {
                    if (barcode.rawValue == null) {
                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          text: "Failed to scan Barcode",
                          backgroundColor: kblack,
                          lottieAsset: "assets/error.json",
                          onConfirmBtnTap: () {
                            KRoutes.popUntil(context);
                          });
                    } else {
                      final String code = barcode.rawValue!;
                      KRoutes.pop(context);
                      KRoutes.push(
                          context,
                          DetailScreen(
                            code: "qr_code=$code",
                            id: societyId,
                            isScan: true,
                          ));
                    }
                  }),
            ),
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:fpzk/Widgets/custom_text.dart';
import 'package:provider/provider.dart';

import '../../Provider/info_provider.dart';

class UpdatedText extends StatelessWidget {
  const UpdatedText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomText(
        text: "${context.watch<InfoProvider>().message}",
        color: context.watch<InfoProvider>().message == "Finger Scanner Running"
            ? Colors.green
            : context.watch<InfoProvider>().message ==
                    "Start Verifying Fingerprints"
                ? Colors.lightGreen
                : Colors.red,
        fontsize: 25,
        textAlign: TextAlign.center);
  }
}

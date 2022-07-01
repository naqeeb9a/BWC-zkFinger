import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MethodChannel methodChannel =
      const MethodChannel("com.example.fpzk/method_channel");
  final EventChannel eventChannel =
      const EventChannel("com.example.fpzk/event_channel");
  String? value;
  Uint8List? image;
  Stream fpData = const Stream.empty();
  getStreamFp() {
    fpData = eventChannel.receiveBroadcastStream().map((event) => event);
    return fpData;
  }

  Map fingerData = {
    "saveFp": null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  onPressed: () async {
                    await methodChannel
                        .invokeMethod("initialize_fingerprint_zk");
                    setState(() {
                      value = "done";
                    });
                  },
                  child: const Text("initialize fingerprint")),
              value == null
                  ? Container()
                  : StreamBuilder(
                      stream: getStreamFp(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        image = base64Decode(snapshot.data["image"]
                            .toString()
                            .replaceAll("\n", "")
                            .replaceAll(" ", ""));
                        if (snapshot.data["saveFp"] != null) {
                          fingerData["saveFp"] = snapshot.data["saveFp"];
                        }
                        return Column(
                          children: [
                            Image.memory(image!),
                            Text(snapshot.data["message"].toString()),
                            Text(snapshot.data["saveFp"].toString()),
                          ],
                        );
                      },
                    ),
              ElevatedButton(
                  onPressed: () async {
                    await methodChannel.invokeMethod("stop_fingerprint_zk");
                  },
                  child: const Text("Stop fingerprint")),
              ElevatedButton(
                  onPressed: () async {
                    await methodChannel.invokeMethod("enroll_fingerprint_zk");
                  },
                  child: const Text("Enroll fingerprint")),
              ElevatedButton(
                  onPressed: () async {
                    await methodChannel.invokeMethod(
                        "verify_fingerprint_zk", fingerData);
                  },
                  child: const Text("Verify fingerprint")),
            ]),
          ),
        ),
      ),
    );
  }
}

import 'package:fpzk/Provider/info_provider.dart';
import 'package:fpzk/Screens/splash_screen.dart';
import 'package:fpzk/Provider/upload_image_list_provider.dart';
import 'package:fpzk/Provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserDataProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => LoginInfoProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SelectedSoceityProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UploadImageListProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => InfoProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BWC Fingerprint Scanner',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

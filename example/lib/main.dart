import 'package:flutter/material.dart';
import 'package:photograffitiflutter/customWidgets/DrawImageView.dart';
import 'package:photograffitiflutter/customWidgets/PictureView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> imageListUrls = List();

  @override
  void initState() {
    super.initState();
    imageListUrls.add( "https://moinvol.infitack.cn/media/public/images/1600763941318.jpg");
    imageListUrls.add("https://moinvol.infitack.cn/media/public/images/1600741181489.jpg");
    imageListUrls.add("https://moinvol.infitack.cn/media/public/images/1600745640405.jpg");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("照片塗鴉"),
        ),
        body: DrawImageView(imageListUrls),
      ),
    );
  }
}

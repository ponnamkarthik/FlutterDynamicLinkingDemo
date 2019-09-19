import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Dynamic Linking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  TextEditingController _editingController = TextEditingController();

  Timer _timerLink;

  _createAndShare() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://bootcamptask.page.link',
      link: Uri.https('yourapp.com', 'cat', {"text": _editingController.text.trim()}),
      androidParameters: AndroidParameters(
        packageName: 'com.example.bootcamp_deeplinking',
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.bootcamp_deeplinking',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Example of a Dynamic Link',
        description: 'This link works whether app is installed or not!',
      ),
    );

    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
    final Uri shortUrl = shortDynamicLink.shortUrl;
    print(shortUrl);
    Share.share('Here is my deeplink $shortUrl');
  }

  
  Future<void> _retrieveDynamicLink() async {
    

    FirebaseDynamicLinks.instance.onLink(onSuccess: (data) async {
      final Uri deepLink = data?.link;

      print("DeepLink is: ${data?.link}");
      if (deepLink != null) {
        deepLink.toString();
        print(deepLink.toString());
        String params = "";
        deepLink.queryParameters.forEach((k,v) {
          params += "$k : $v \n"; 
        });
        // Here we need to perform operations and navigation based on data we received
        showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text("Data you sent"),
              children: <Widget>[
                Center(
                  child: Text(
                    params,
                  ),
                )
              ],
            );
          }
        );
      }
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.resumed) {
      _timerLink =
          Timer(Duration(milliseconds: 500), () => _retrieveDynamicLink());
    }
  }

  @override
  void dispose() {
    _timerLink.cancel();
    super.dispose();
  }



  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Deep Linking"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _editingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Text To Share",
              ),
            ),
          ),
          RaisedButton(
            child: Text("Create DeepLink and Share"),
            onPressed: () {
              _createAndShare();
            },
          )
        ],
      ),
    );
  }
}

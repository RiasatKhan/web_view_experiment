import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();
  await Permission.microphone.request();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: InAppWebViewPage());
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  InAppWebViewController webView;

  // Future<bool> _goBack() async {
  //   if (await _webViewController.canGoBack()) {
  //     print("Sakif");
  //     _webViewController.goBack();
  //     return Future.value(true);
  //   } else {
  //     Scaffold.of(context).showSnackBar(
  //       const SnackBar(content: Text("No back history item")),
  //     );
  //     return Future.value(false);
  //   }
  // }

  Future<bool> _onBack() async {
    bool goBack;

    var value = await webView.canGoBack(); // check webview can go back
    var url = await webView.getUrl();
    print(url);
    if (url == "https://doctor-dev.takemed.com.bd/portal" ||
        url == "https://doctor-dev.takemed.com.bd/") {
      await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title:
              new Text('Confirmation ', style: TextStyle(color: Colors.purple)),

          // Are you sure?

          content: new Text('Do you want exit app ? '),

          // Do you want to go back?

          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop(false);

                setState(() {
                  goBack = false;
                });
              },

              child: new Text("No"), // No
            ),
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();

                setState(() {
                  goBack = true;
                });
                SystemNavigator.pop();
              },

              child: new Text("Yes"), // Yes
            ),
          ],
        ),
      );

      if (goBack) Navigator.pop(context); // If user press Yes pop the page

      return goBack;
    } else if (value) {
      webView.goBack(); // perform webview back operation
      print(url);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBack,
        child: Scaffold(
            body: SafeArea(
                child: Container(
                    child: Column(children: <Widget>[
          Expanded(
            child: Container(
              child: InAppWebView(
                  initialUrl: "https://doctor-dev.takemed.com.bd/",
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      mediaPlaybackRequiresUserGesture: false,
                      debuggingEnabled: true,
                    ),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                  },
                  androidOnPermissionRequest:
                      (InAppWebViewController controller, String origin,
                          List<String> resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  }),
            ),
          ),
        ])))));
  }
}

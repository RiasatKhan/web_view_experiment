import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'api.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.storage.request();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InAppWebViewPage(),
    );
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  InAppWebViewController _webViewController;

  String url;




  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _message = '';
  var token = '';
  
  _registerOnFirebase() async {
    _firebaseMessaging.subscribeToTopic('all');
    token =  await _firebaseMessaging.getToken();
    print('Token===============================================================================================================>>>>');
    print(token);
  }

  @override
  void initState() {
    _registerOnFirebase();
    getMessage();
    super.initState();
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('received message');
      setState(() => _message = message["notification"]["body"]);
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _message = message["notification"]["body"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["body"]);
    });
  }


 Future <bool> callMuation() async {
    var localStorage = _webViewController.webStorage.localStorage;
    print('====================================================================');
    String deviceUuid = await localStorage.getItem(key: 'deviceUuid');
    print(deviceUuid);
    print(setDeviceTokenForDoctor);
     print('Token===2nd============================================================================================================>>>>');
    print(token);
    MutationOptions mutationOptions = MutationOptions(
      documentNode: gql(setDeviceTokenForDoctor),
      variables: <String, dynamic>{
        'deviceUuid': deviceUuid,
        'deviceToken': token
      },
    );
    QueryResult result = await client.value.mutate(mutationOptions);
    print("result ======================================================================================================>>>>>>");
    print(result.data.toString());
    return true;
  }


  

  Future<bool> _onBack() async {
    bool goBack;

    var value =
        await _webViewController.canGoBack(); // check webview can go back
    print('print url->>>>>>>>>>>>>>>>>>>>>');
    print(url);
    
    //print (_webViewController.printCurrentPage());
    if (url == 'https://doctor-dev.takemed.com.bd/' ||
        url == 'https://doctor-dev.takemed.com.bd/portal') {
      print('inside if');
      setState(() {
        goBack = false;
      });
      value = false;
    }
    if (value) {
      _webViewController.goBack(); // perform webview back operation
      return false;
    } else {
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

              child: new Text('NO'), // No
            ),
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();

                setState(() {
                  goBack = true;
                });
              },

              child: new Text('YES'), // Yes
            ),
          ],
        ),
      );

      if (goBack) Navigator.pop(context); // If user press Yes pop the page

      return goBack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBack,
        child: Scaffold(
          body: Container(
            child: Column(
              children: <Widget>[
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
                          _webViewController = controller;
                        },
                        onLoadStart:
                            (InAppWebViewController controller, String url) {
                          setState(() {
                            this.url = url;
                          });
                        },
                        onLoadStop: (InAppWebViewController controller,
                            String url) async {
                          setState(() {
                            this.url = url;
                          });
                          callMuation();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: Container(
        child: Center(
          child: Text("Hey,there!"),
        ),
      ),
    );
  }
}

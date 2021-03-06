import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';
import 'main.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      new _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  InAppWebViewController webView;
  ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  CookieManager _cookieManager = CookieManager.instance();
  String script = """ function click() { 
                         const refreshBtn = document.querySelector('.loadboard-reload__refresh-icon--reload-icon');
                         refreshBtn.click() 
                         };
                         
                         
function isFinded() {
    summaryText = document.querySelector('.summary-text')
    text = summaryText.textContent || summaryText.innerText;
    //  console.log(text)
    if (text[0] == '0')
        return false
    else return true
        
}


                         
                         """;

  String script2 = """ click(); 
                         """;

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webView.getSelectedText());
                await webView.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: true),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webView.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("InAppWebView")),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(children: <Widget>[
//          Container(
//            padding: EdgeInsets.all(20.0),
//            child: Text(
//                "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
//          ),
          Container(
              padding: EdgeInsets.all(10.0),
              child: progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container()),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: InAppWebView(
                  contextMenu: contextMenu,
                  initialUrl: "https://relay.amazon.com/tours/loadboard?",
                  // initialFile: "assets/index.html",
                  initialHeaders: {},
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                        debuggingEnabled: true,
                        useShouldOverrideUrlLoading: true,
                        javaScriptCanOpenWindowsAutomatically: true),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    webView = controller;
                    print("onWebViewCreated");

                    controller.addJavaScriptHandler(
                        handlerName: "mySum1",
                        callback: (args) {
                          // Here you receive all the arguments from the JavaScript side
                          // that is a List<dynamic>
                          print("From the JavaScript side 1:");
                          print(args);
                          return args.reduce((curr, next) => curr + next);
                        });

                    controller.addJavaScriptHandler(
                        handlerName: "mySum2",
                        callback: (args) {
                          // Here you receive all the arguments from the JavaScript side
                          // that is a List<dynamic>
                          print("From the JavaScript side 2:");
                          print(args);

                          if (args[0] != true) {
                            clickWithDelay(2000);
                            print("not true");
                          }
                          return args.reduce((curr, next) => curr + next);
                        });
                  },
                  onConsoleMessage: (InAppWebViewController controller,
                      ConsoleMessage consoleMessage) {
                    print("console message: ${consoleMessage.message}");
                  },
                  onLoadStart: (InAppWebViewController controller, String url) {
                    print("onLoadStart $url");
                    setState(() {
                      this.url = url;
                    });
                  },
                  shouldOverrideUrlLoading:
                      (controller, shouldOverrideUrlLoadingRequest) async {
                    print("shouldOverrideUrlLoading");
                    return ShouldOverrideUrlLoadingAction.ALLOW;
                  },
                  onLoadStop:
                      (InAppWebViewController controller, String url) async {
                    print("onLoadStop $url");
                    setState(() {
                      this.url = url;
                    });

                    webView.evaluateJavascript(source: script);
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onUpdateVisitedHistory: (InAppWebViewController controller,
                      String url, bool androidIsReload) {
                    print("onUpdateVisitedHistory $url");
                    setState(() {
                      this.url = url;
                    });
                  }),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Icon(Icons.arrow_back),
                onPressed: () {
                  if (webView != null) {
                    //  webView.javaScriptCanOpenWindowsAutomatically;
                    //  const script="const zz=document.querySelector('.btn-collapser'); zz.click();";
                    //  clickRefresh();
                    clickWithDelay(2000);

                    //  webView.goBack();
                  }
                },
              ),
              RaisedButton(
                child: Icon(Icons.arrow_forward),
                onPressed: () {
                  if (webView != null) {
                    webView.goForward();
                  }
                },
              ),
              RaisedButton(
                child: Icon(Icons.refresh),
                onPressed: () {
                  if (webView != null) {
                    webView.reload();
                  }
                },
              ),
            ],
          ),
        ])));
  }

  void clickRefresh() async {
    print("click2");

    webView.evaluateJavascript(source: """
    window.flutter_inappwebview.callHandler('mySum2', isFinded()).then(
    //console.log (isFinded())
    console.log('dddd')
    );
  """);

    String result3 = await webView.evaluateJavascript(source: script2);
    print(result3);
  }

  void clickWithDelay(int delayMs) {
    const delay = const Duration(milliseconds: 2000);
    new Timer(delay, () => clickRefresh());
  }

  void startRefresh() {
    clickRefresh();
   // if (!checkForResult()) {}
  }

  bool checkForResult() {
    return true;
  }
}

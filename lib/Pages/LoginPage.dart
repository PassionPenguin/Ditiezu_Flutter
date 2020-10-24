import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/parsing.dart';

import '../Data/Arrays.dart';
import '../Models/User.dart';
import '../Network/Network.dart';
import '../Provider/UserModel.dart';
import '../Route/Routes.dart';
import '../Widgets/v_empty_view.dart';
import '../Widgets/w_iconMessage.dart';
import '../Widgets/w_input.dart';
import '../app.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // InputController
  final TextEditingController _usrNameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  ImageProvider codeImage = AssetImage("assets/images/logo.png");
  String codeHash;
  int questionID = 0;
  bool isLoading = false;
  String formAction;
  String formHash;

  Future<NetworkImage> loadCode() async {
    /**
     * [Function] loadCode(hash: String)
     * @param hash: String, the code hash (or sechash)
     * @return null
     * @purpose show security code -> ImageView
     */
    var response = await NetWork().get("http://www.ditiezu.com/misc.php?mod=seccode&action=update&idhash=$codeHash&inajax=1&ajaxtarget=seccode_");
    var doc = parseHtmlDocument(parseXmlDocument(response).firstChild.text); // <CDATA>
    return NetworkImage("http://www.ditiezu.com/" + doc.querySelector("img").attributes["src"], headers: {
      "user-agent": "Mozilla/5.0 (Linux; Android 12;) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.126 MQQBrowser/6.2 TBS/045111 Mobile Safari/537.36 Process/tools NetType/WIFI Language/zh_CN ABI/arm64",
      "cookie": PersistCookieJar(dir: (await getApplicationDocumentsDirectory()).path + "/.cookies/").loadForRequest(Uri.http("www.ditiezu.com", "")).join("")
    });
  }

  _init() {
    () async {
      if (await NetWork().checkLogin()) {
        setState(() {
          message = "正在跳转中";
          color = Colors.green;
          icon = Icons.check;
          isMessageShowing = true;
          isLoading = false;
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isMessageShowing = false;
            });
          });
        });
        Future.delayed(Duration(seconds: 2), () {
          Routes.navigateTo(context, "/home");
        });
        return;
      }

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
      if (cookieJar.loadForRequest(Uri.http("www.ditiezu.com", "")).isEmpty) await NetWork().get("http://www.ditiezu.com/forum.php?mod=forum");
      var response = await NetWork.mobile(autoRedirect: false).get("http://www.ditiezu.com/member.php?mod=logging&action=login&mobile=yes");
      if (response.contains("./?mobile=yes")) {
        setState(() {
          message = "正在跳转中";
          color = Colors.green;
          icon = Icons.check;
          isMessageShowing = true;
          isLoading = false;
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isMessageShowing = false;
            });
          });
        });
        Future.delayed(Duration(seconds: 2), () {
          Routes.navigateTo(context, "/home");
        });
        Application.user.loginState = true;
        UserModel.saveUserInfo(Application.user);
        return;
      }
      var doc = parseHtmlDocument(response);
      codeHash = doc.querySelector(".scod").attributes["src"];
      codeHash = codeHash.substring(codeHash.length - 5);
      codeImage = await loadCode();
      formAction = doc.querySelector("form").attributes["action"];
      formHash = doc.querySelector("[name='formhash']").attributes["value"];
      setState(() {});
    }();
  }

  bool isMessageShowing = false;
  String message = "";
  IconData icon = Icons.check;
  Color color = Colors.green;
  Map<String, Animation<double>> _fadeAnimation = {};
  Map<String, AnimationController> _fadeController = {};

  String credit;

  @override
  void initState() {
    _fadeController["main"] = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeController["messaging"] = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation["main"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController["main"]);
    _fadeAnimation["messaging"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController["messaging"]);
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    if (isMessageShowing) {
      _fadeController["main"].reverse();
      _fadeController["messaging"].forward();
    } else {
      _fadeController["main"].forward();
      _fadeController["messaging"].reverse();
    }
    var el = Stack(children: [
      new Visibility(
          visible: !isMessageShowing,
          child: new FadeTransition(
              opacity: _fadeAnimation["main"],
              child: Container(
                  padding: EdgeInsets.only(
                    left: 80,
                    right: 80,
                    top: 30,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Hero(
                      tag: 'TitleText',
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                        VEmptyView(6),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 34,
                          ),
                        ),
                        VEmptyView(6),
                        Text(
                          'The Flutter Ditiezu App',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(height: 24),
                      TextInput(_usrNameController, TextInputType.text, prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.person, color: Colors.grey, size: 16)]), placeholder: "用户名"),
                      SizedBox(height: 24),
                      TextInput(_pwdController, TextInputType.visiblePassword, prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.lock, color: Colors.grey, size: 16)]), placeholder: "密码", obscureText: true),
                      SizedBox(height: 24),
                      Row(children: [
                        Container(
                          width: 60,
                          height: 36,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.white),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    () async {
                                      codeImage = await loadCode();
                                      setState(() {});
                                    }();
                                  },
                                  child: Image(image: codeImage, width: 48, fit: BoxFit.contain))
                            ],
                          ),
                        ),
                        Expanded(child: TextInput(_codeController, TextInputType.text, prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.code, color: Colors.grey, size: 16)]), placeholder: "验证码"))
                      ]),
                      SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: DropdownButton<String>(
                                style: TextStyle(fontSize: 14, color: Colors.black),
                                items: questionName.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onChanged: (value) {
                                  questionID = questionName.indexOf(value);
                                  setState(() {});
                                },
                                value: questionName[questionID]))
                      ]),
                      Row(children: [
                        Expanded(child: TextInput(_questionController, TextInputType.text, prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.question_answer, color: Colors.grey, size: 16)]), placeholder: "答案"))
                      ]),
                      SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: MaterialButton(
                          height: 48,
                          elevation: 0,
                          child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Wrap(children: [
                                Offstage(
                                    offstage: isLoading,
                                    child: AnimatedOpacity(
                                        opacity: isLoading ? 0 : 1, duration: Duration(seconds: 1), child: SizedBox(height: 20, child: Text("登录", style: TextStyle(color: Colors.black, fontSize: 14, height: 1.4, fontWeight: FontWeight.w400))))),
                                Offstage(
                                    offstage: !isLoading,
                                    child: AnimatedOpacity(
                                        opacity: isLoading ? 1 : 0,
                                        duration: Duration(seconds: 1),
                                        child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation(Colors.white),
                                              backgroundColor: Colors.lightBlue[200],
                                              strokeWidth: 3,
                                            ))))
                              ])),
                          onPressed: performLogin,
                          color: Colors.lightBlue[200],
                        ))
                      ]),
                      VEmptyView(24),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [Image.asset("assets/images/vector_welcome.png", width: 128)])
                    ]),
                  ])))),
      new Visibility(visible: isMessageShowing, child: new FadeTransition(opacity: _fadeAnimation["messaging"], child: Center(child: IconMessage(icon: icon, color: color, message: message)))),
//      Positioned(child: , bottom: 0, right: 0)
    ]);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
      ),
      body: SingleChildScrollView(
        child: el,
      ),
    );
  }

  void performLogin() async {
    setState(() {
      isLoading = true;
    });
    var response = await NetWork.mobile(autoRedirect: false).post("http://www.ditiezu.com/$formAction",
        "formhash=$formHash&referer=http%3A%2F%2Fwww.ditiezu.com%2Fforum.php%3Fmod%3Dforum%26mobile%3Dyes&username=${Uri.encodeComponent(_usrNameController.text)}&password=${Uri.encodeComponent(_pwdController.text)}&sechash=$codeHash&seccodeverify=${Uri.encodeComponent(_codeController.text)}&questionid=$questionID&answer=${Uri.encodeComponent(_questionController.text)}&cookietime=15552000&submit=%E7%99%BB%E5%BD%95");
    var doc = parseHtmlDocument(response);
    if (response.contains("forum.php?mod=forum") && !response.contains("<head>") || doc.querySelector("#messagetext .mbn") == null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
      cookieJar.deleteAll();
      _init();
      codeImage = await loadCode();
      setState(() {});
      return;
    }
    var status = doc.querySelector("#messagetext .mbn").text.contains("欢迎您回来");
    setState(() {
      message = doc.querySelector("#messagetext .mbn").text;
      color = status ? Colors.green : Colors.red;
      icon = status ? Icons.check : Icons.clear;
      isMessageShowing = true;
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isMessageShowing = false;
        });
      });
    });
    if (status) {
      var usr = User(
          uid: int.parse(response.substring(response.indexOf("discuz_uid = '") + 14, response.indexOf("'", response.indexOf("discuz_uid = '") + 14))),
          userName: response.substring(response.indexOf("欢迎您回来，") + 6, response.indexOf("。", response.indexOf("欢迎您回来，"))),
          loginState: true);
      Application.user = usr;
      UserModel.saveUserInfo(usr);
      Future.delayed(Duration(seconds: 3), () {
        Routes.navigateTo(context, "/home");
      });
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
      cookieJar.deleteAll();
      _init();
      codeImage = await loadCode();
      setState(() {});
    }
    isLoading = false;
    setState(() {});
  }
}

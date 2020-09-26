import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:ditiezu_app/Network/network.dart';
import 'package:ditiezu_app/Route/routes.dart';
import 'package:ditiezu_app/app.dart';
import 'package:ditiezu_app/data/arrays.dart';
import 'package:ditiezu_app/model/user.dart';
import 'package:ditiezu_app/provider/user_model.dart';
import 'package:ditiezu_app/widgets/w_input.dart';
import 'package:ditiezu_app/widgets/w_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/parsing.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      "user-agent":
          "Mozilla/5.0 (Linux; Android 12;) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.126 MQQBrowser/6.2 TBS/045111 Mobile Safari/537.36 Process/tools NetType/WIFI Language/zh_CN ABI/arm64",
      "cookie": PersistCookieJar(dir: (await getApplicationDocumentsDirectory()).path + "/.cookies/").loadForRequest(Uri.http("www.ditiezu.com", "")).join("")
    });
  }

  @override
  void initState() {
    super.initState();
    () async {
      if (Application.user != null && Application.user.loginState) {
        Toast(context, "正在跳转中", accentColor: Colors.lightGreen, icon: CupertinoIcons.check_mark);
        isLoading = false;
        setState(() {});
        Future.delayed(Duration(seconds: 2), () {
          Routes.navigateTo(context, "/home");
        });
        return;
      }

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
      if (cookieJar.loadForRequest(Uri.http("www.ditiezu.com", "")).isEmpty) await NetWork(retrieveAsDesktopPage: false, gbkDecoding: false).get("http://www.ditiezu.com/forum.php?mod=forum");
      var response = await NetWork(retrieveAsDesktopPage: false, gbkDecoding: false, autoRedirect: false).get("http://www.ditiezu.com/member.php?mod=logging&action=login&mobile=yes");
      if (response.contains("./?mobile=yes")) {
        Toast(context, "正在跳转中", accentColor: Colors.lightGreen, icon: CupertinoIcons.check_mark);
        isLoading = false;
        setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: 80,
            right: 80,
            top: 30,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/images/logo.png',
                width: 48,
                height: 48,
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Container(
                margin: EdgeInsets.only(top: 18),
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 34,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 3),
                child: Text(
                  'The Flutter Ditiezu App',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextInput(_usrNameController, TextInputType.text,
                  prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.person, color: Colors.grey, size: 16)]), placeholder: "User Name", style: TextStyle(fontSize: 14)),
              SizedBox(height: 24),
              TextInput(_pwdController, TextInputType.visiblePassword,
                  prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.lock, color: Colors.grey, size: 16)]),
                  placeholder: "Password",
                  style: TextStyle(fontSize: 14),
                  obscureText: true),
              SizedBox(height: 24),
              Row(children: [
                Container(
                  width: 60,
                  height: 36,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(image: codeImage, width: 48, fit: BoxFit.contain),
                    ],
                  ),
                ),
                Expanded(
                    child: TextInput(_codeController, TextInputType.text,
                        prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.code, color: Colors.grey, size: 16)]),
                        placeholder: "Code",
                        style: TextStyle(fontSize: 14),
                        obscureText: true))
              ]),
              SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: DropdownButton<String>(
                        items: questionName.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) {
                          questionID = questionName.indexOf(value);
                          setState(() {});
                        },
                        value: questionName[questionID]))
              ]),
              Row(children: [
                Expanded(
                    child: TextInput(_questionController, TextInputType.text,
                        prefix: Row(children: [Padding(padding: EdgeInsets.only(left: 12)), Icon(Icons.question_answer, color: Colors.grey, size: 16)]),
                        placeholder: "Answer",
                        style: TextStyle(fontSize: 14),
                        obscureText: true))
              ]),
              SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: CupertinoButton(
                  child: Wrap(children: [
                    Offstage(
                        offstage: isLoading,
                        child: AnimatedOpacity(
                            opacity: isLoading ? 0 : 1,
                            duration: Duration(seconds: 1),
                            child: SizedBox(height: 20, child: Text("LOGIN", style: TextStyle(fontSize: 18, height: 1.25, fontWeight: FontWeight.w600))))),
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
                                  backgroundColor: Colors.lightBlue,
                                  strokeWidth: 3,
                                ))))
                  ]),
                  onPressed: performLogin,
                  color: Colors.lightBlue,
                ))
              ])
            ]),
          ]),
        ),
      ),
    );
  }

  void performLogin() async {
    isLoading = true;
    setState(() {});
    var response = await NetWork().post("http://www.ditiezu.com/$formAction",
        "formhash=$formHash&referer=http%3A%2F%2Fwww.ditiezu.com%2Fforum.php%3Fmod%3Dforum%26mobile%3Dyes&username=${Uri.encodeComponent(_usrNameController.text)}&password=${Uri.encodeComponent(_pwdController.text)}&sechash=$codeHash&seccodeverify=${Uri.encodeComponent(_codeController.text)}&questionid=$questionID&answer=${Uri.encodeComponent(_questionController.text)}&cookietime=2592000&submit=%E7%99%BB%E5%BD%95");
    if (response.contains("forum.php?mod=forum") && !response.contains("<head>")) {
      Toast(context, "正在跳转中", accentColor: Colors.lightGreen, icon: CupertinoIcons.check_mark);
      isLoading = false;
      setState(() {});
      Future.delayed(Duration(seconds: 2), () {
        Routes.navigateTo(context, "/home");
      });
      return;
    }
    var doc = parseHtmlDocument(response);
    var status = doc.querySelector("#messagetext .mbn").innerHtml.contains("欢迎您回来");
    Toast(context, doc.querySelector("#messagetext .mbn").innerHtml, accentColor: status ? Colors.lightGreen : Colors.red, icon: status ? CupertinoIcons.check_mark : CupertinoIcons.clear);
    if (status) {
      var usr = User(
          uid: int.parse(response.substring(response.indexOf("discuz_uid = '") + 14, response.indexOf("'", response.indexOf("discuz_uid = '") + 14))),
          userName: response.substring(response.indexOf("欢迎您回来，") + 6, response.indexOf("。", response.indexOf("欢迎您回来，"))),
          loginState: true);
      Application.user = usr;
      UserModel.saveUserInfo(usr);
      Future.delayed(Duration(seconds: 2), () {
        Routes.navigateTo(context, "/home");
      });
    }
    if (doc.querySelector("#messagetext .mbn").innerHtml.contains("验证码填写错误")) {
      initState();
    }
    isLoading = false;
    setState(() {});
  }
}

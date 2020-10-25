import 'dart:io';

import 'package:Ditiezu/Widgets/InteractivePage.dart';
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
import '../Widgets/w_input.dart';
import '../app.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin, InteractivePage {
  // InputControllers
  final TextEditingController _usrNameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  // Verification code
  ImageProvider codeImage = AssetImage("assets/images/logo.png");
  String codeHash; // -> idhash
  // QA Verification
  int questionID = 0;

  // Form Url & Hash
  String formAction;
  String formHash; // -> formhash

  @override
  void initState() {
    super.initState();
    super.bindIntractableWidgets(false, this);
    init();
  }

  @override
  Widget build(BuildContext context) {
    var el = Stack(children: [
      new Visibility(
          visible: !isMessageShowing,
          child: new FadeTransition(
              opacity: fadeAnimation["main"],
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
      new Visibility(visible: isMessageShowing, child: new FadeTransition(opacity: fadeAnimation["messaging"], child: Center(child: icnMessage())))
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
      isLoading = true; // This variable is mutable to indicate the SubmitButton's animation instead of the interactive page.
    });
    /* [API] Login Form
      @method POST
      @url http://www.ditiezu.com/member.php?mod=logging&action=login&loginsubmit=yes&loginhash=[login hash]
      @formData
        (String) formhash, (static String) referer, (String, utf8) username, (String, utf8) password, (String) sechash, (String) secverify, (int) questionid, (String) answer, (static int) cookietime, (static String) submit
      @expected
        Succeed: $("#messagetext .mbn").text.contains("欢迎您回来")
        Error: !Succeed
     */
    var response = await NetWork.mobile(autoRedirect: false).post("http://www.ditiezu.com/$formAction",
        "formhash=$formHash&referer=http%3A%2F%2Fwww.ditiezu.com%2Fforum.php%3Fmod%3Dforum%26mobile%3Dyes&username=${Uri.encodeComponent(_usrNameController.text)}&password=${Uri.encodeComponent(_pwdController.text)}&sechash=$codeHash&seccodeverify=${Uri.encodeComponent(_codeController.text)}&questionid=$questionID&answer=${Uri.encodeComponent(_questionController.text)}&cookietime=15552000&submit=%E7%99%BB%E5%BD%95");
    var doc = parseHtmlDocument(response);

    if (response.contains("forum.php?mod=forum") && !response.contains("<head>") || doc.querySelector("#messagetext .mbn") == null) {
      // Have logged in, but is needed to re-log in to get the username and the uid.
      // The following code will remove the cookie and re-initialize the page.
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
      cookieJar.deleteAll();
      init();
      codeImage = await loadCode();
      setState(() {});
      return;
    }

    var status = doc.querySelector("#messagetext .mbn").text.contains("欢迎您回来");
    setAnim(false, true, doc.querySelector("#messagetext .mbn").text, status ? Colors.green : Colors.red, status ? Icons.check : Icons.clear);
    if (status) {
      // Save the username and the uid.
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
      init();
      codeImage = await loadCode();
      setState(() {});
    }
    isLoading = false;
    setState(() {});
  }

  Future<NetworkImage> loadCode() async {
    /**
     * [Function] loadCode(hash: String)
     * @param hash: String, the code hash (or sechash)
     * @return null
     * @purpose show security code -> ImageView
     */

    /* [API] Login Verification Code Url Getter
      @method GET
      @url http://www.ditiezu.com/misc.php?mod=seccode&action=update&idhash=[code hash]&inajax=1&ajaxtarget=seccode_
      @expected
        Succeed: codeUrl = $("img").attributes["src"]
     */
    var response = await NetWork().get("http://www.ditiezu.com/misc.php?mod=seccode&action=update&idhash=$codeHash&inajax=1&ajaxtarget=seccode_");
    var doc = parseHtmlDocument(parseXmlDocument(response).firstChild.text); // <CDATA>

    /* [API] Login Verification Code Downloader
      @method GET
      @url http://www.ditiezu.com/misc.php?mod=seccode&update=[update]&idhash=[code hash]
      @expected
        Succeed: image data
     */
    return NetworkImage("http://www.ditiezu.com/" + doc.querySelector("img").attributes["src"], headers: {
      "user-agent": "Mozilla/5.0 (Linux; Android 12;) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.126 MQQBrowser/6.2 TBS/045111 Mobile Safari/537.36 Process/tools NetType/WIFI Language/zh_CN ABI/arm64",
      "cookie": PersistCookieJar(dir: (await getApplicationDocumentsDirectory()).path + "/.cookies/").loadForRequest(Uri.http("www.ditiezu.com", "")).join("")
    });
  }

  void init() {
    () async {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
      if (await NetWork().checkLogin()) cookieJar.deleteAll(); // If is logged in but still here, then remove the cookie to perform a re-log in.

      if (cookieJar.loadForRequest(Uri.http("www.ditiezu.com", "")).isEmpty) await NetWork().get("http://www.ditiezu.com/forum.php?mod=forum"); // This page requires cookie? existed or it will return an empty document.

      /* [API] Login Page Retriever
      @method GET
      @url http://www.ditiezu.com/member.php?mod=logging&action=login&mobile=yes
      @expected
        Succeed: HTML document
     */
      var response = await NetWork.mobile(autoRedirect: false).get("http://www.ditiezu.com/member.php?mod=logging&action=login&mobile=yes");
      if (response.contains("./?mobile=yes")) {
        // If is logged in but still here, then remove the cookie to perform a re-log in.
        cookieJar.deleteAll();
        await NetWork().get("http://www.ditiezu.com/forum.php?mod=forum");
        response = await NetWork.mobile(autoRedirect: false).get("http://www.ditiezu.com/member.php?mod=logging&action=login&mobile=yes");
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
}

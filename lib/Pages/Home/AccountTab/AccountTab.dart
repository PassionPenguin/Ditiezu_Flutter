import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/parsing.dart';

import '../../../Models/User.dart';
import '../../../Network/Network.dart';
import '../../../Provider/UserModel.dart';
import '../../../Route/Routes.dart';
import '../../../Utils/Exts.dart';
import '../../../Widgets/v_empty_view.dart';
import '../../../Widgets/w_confirm.dart';
import '../../../Widgets/w_setting.dart';
import '../../../app.dart';

class AccountTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  String lv = "";
  int pts = 1;
  int prestige = 100;
  int money = 100;
  int mScore = 100;
  int popularity = 100;
  int friends = 100;
  int replies = 100;
  int posts = 100;

  @override
  void initState() {
    () async {
      var response = await NetWork().get("http://www.ditiezu.com/home.php?mod=space");
      var doc = parseHtmlDocument(response);
      if (doc.querySelector("#wp").innerHtml.contains('<a id="succeedmessage_href">如果你的浏览器没有自动跳转，请点击此链接</a>')) Routes.navigateTo(context, "/login");
      try {
        var pts = doc.querySelector("#psts li").text.substring(2).trim().toInt();
        lv = doc.querySelector(".pbm span a").text;
        this.pts = pts;
        this.prestige = doc.querySelectorAll("#psts li")[1].nodes[1].text.trim().toInt();
        this.money = doc.querySelectorAll("#psts li")[2].nodes[1].text.trim().toInt();
        this.mScore = doc.querySelectorAll("#psts li")[3].nodes[1].text.trim().toInt();
        this.popularity = doc.querySelectorAll("#psts li")[4].nodes[1].text.trim().toInt();

        var meta = doc.querySelector(".cl.bbda.pbm.mbm").querySelectorAll("li").where((i) {
          return i.children[0].innerText == "统计信息";
        }).first;
        this.friends = meta.querySelectorAll("a")[0].text.trim().substring(4).toInt();
        this.replies = meta.querySelectorAll("a")[1].text.trim().substring(4).toInt();
        this.posts = meta.querySelectorAll("a")[2].text.trim().substring(4).toInt();
        setState(() {});
      } catch (e) {
        print(e);
      }
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var page = Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(children: [
          Row(children: [
            Padding(
                padding: EdgeInsets.only(right: 16),
                child: ClipRRect(borderRadius: BorderRadius.circular(48), child: Image(image: NetworkImage("http://ditiezu.com/uc_server/avatar.php?mod=avatar&uid=${Application.user.uid}"), width: 96, height: 96, fit: BoxFit.cover))),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    Text(Application.user.userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Padding(padding: EdgeInsets.only(left: 8, right: 2), child: Icon(Icons.qr_code, color: Colors.black)),
                  ])),
              Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("UID: ${Application.user.uid}")),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                      padding: EdgeInsets.all(2), decoration: BoxDecoration(border: Border.all(color: Colors.redAccent), borderRadius: BorderRadius.circular(4.0)), child: Text(lv, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
            ])
          ]),
          VEmptyView(24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_stateDisplay("积分", pts.toString()), _stateDisplay("威望", prestige.toString()), _stateDisplay("金钱", money.toString()), _stateDisplay("M值", mScore.toString())]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_stateDisplay("人气", popularity.toString()), _stateDisplay("好友", friends.toString()), _stateDisplay("回帖数", replies.toString()), _stateDisplay("主题帖", posts.toString())]),
          VEmptyView(24),
          Column(children: [
            Setting("清除缓存", "清除APP留下的所有的缓存数据", () {
              Confirm(context, "清理缓存", "确认清理缓存？", () {
                () async {
                  var appDir = (await getTemporaryDirectory()).path;
                  new Directory(appDir).delete(recursive: true);
                }();
              });
            }),
            Setting("编辑个签", "编辑个性签名(SIGHTML)", () {
              Routes.navigateTo(context, Routes.post, params: {"mode": "SIGHTML"});
            }),
            Setting("版本数据", "当前版本 ${Application.CHANNEL} ${Application.VERSION_NAME}", () {}, type: Setting.TYPE_NOTING),
            Setting("隐私政策", null, () {
              Routes.navigateTo(context, "/privacy");
            }),
            Setting("用户协议", null, () {
              Routes.navigateTo(context, "/license");
            }),
            Setting("开源许可", null, () {
              Routes.navigateTo(context, "/openSourceLicense");
            }),
            InkWell(
                onTap: () {
                  Confirm(context, "退出账号", "确认退出账号？", () {
                    () async {
                      Directory appDocDir = await getApplicationDocumentsDirectory();
                      String appDocPath = appDocDir.path;
                      var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
                      cookieJar.deleteAll();
                      UserModel.saveUserInfo(User(uid: 0, userName: "", loginState: false));
                      Routes.navigateTo(context, "/login", clearStack: true);
                    }();
                  });
                },
                child: Container(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), child: Center(child: Text("退出账号", style: TextStyle(color: Colors.red)))))
          ])
        ]));
    return Scaffold(body: SingleChildScrollView(child: page));
  }

  _stateDisplay(String name, String value) {
    return Container(width: 72, height: 48, padding: EdgeInsets.all(4), child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [Text(value), Text(name)]));
  }
}

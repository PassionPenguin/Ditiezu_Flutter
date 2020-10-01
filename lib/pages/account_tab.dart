import 'package:ditiezu_app/Network/network.dart';
import 'package:ditiezu_app/app.dart';
import 'package:ditiezu_app/utils/exts.dart';
import 'package:ditiezu_app/widgets/v_empty_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/parsing.dart';

class AccountTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  String lv = "";
  int pts;
  int prestige;
  int money;
  int mScore;
  int popularity;
  int friends;
  int replies;
  int posts;

  @override
  void initState() {
    () async {
      var response =
          await NetWork(retrieveAsDesktopPage: true, gbkDecoding: true)
              .get("http://www.ditiezu.com/home.php?mod=space");
      var doc = parseHtmlDocument(response);
      var pts = doc.querySelector("#psts li").text.substring(2).trim().toInt();
      var max = pts.isIn(1, 49)
          ? 50
          : pts.isIn(50, 199)
              ? 200
              : pts.isIn(200, 499)
                  ? 500
                  : pts.isIn(500, 999)
                      ? 1000
                      : pts.isIn(1000, 2999)
                          ? 3000
                          : pts.isIn(3000, 4999)
                              ? 5000
                              : pts.isIn(5000, 9999)
                                  ? 10000
                                  : pts.isIn(10000, 19999)
                                      ? 20000
                                      : pts.isIn(20000, 49999)
                                          ? 50000
                                          : 0;
      var min = pts.isIn(1, 49)
          ? 0
          : pts.isIn(50, 199)
              ? 50
              : pts.isIn(200, 499)
                  ? 200
                  : pts.isIn(500, 999)
                      ? 500
                      : pts.isIn(1000, 2999)
                          ? 1000
                          : pts.isIn(3000, 4999)
                              ? 3000
                              : pts.isIn(5000, 9999)
                                  ? 5000
                                  : pts.isIn(10000, 19999)
                                      ? 10000
                                      : pts.isIn(20000, 49999)
                                          ? 20000
                                          : 0;
      lv = doc.querySelector(".pbm span a").text;
      this.pts = pts;
      this.prestige =
          doc.querySelectorAll("#psts li")[1].nodes[1].text.trim().toInt();
      this.money =
          doc.querySelectorAll("#psts li")[2].nodes[1].text.trim().toInt();
      this.mScore =
          doc.querySelectorAll("#psts li")[3].nodes[1].text.trim().toInt();
      this.popularity =
          doc.querySelectorAll("#psts li")[4].nodes[1].text.trim().toInt();

      var meta = doc
          .querySelector(".cl.bbda.pbm.mbm")
          .querySelectorAll("li")
          .where((i) {
        return i.children[0].innerText == "统计信息";
      }).first;
      this.friends =
          meta.querySelectorAll("a")[0].text.trim().substring(4).toInt();
      this.replies =
          meta.querySelectorAll("a")[1].text.trim().substring(4).toInt();
      this.posts =
          meta.querySelectorAll("a")[2].text.trim().substring(4).toInt();
      setState(() {});
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(children: [
              Row(children: [
                Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(48),
                        child: Image(
                            image: NetworkImage(
                                "http://ditiezu.com/uc_server/avatar.php?mod=avatar&uid=${Application.user.uid}"),
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover))),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Text(Application.user.userName,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Padding(
                            padding: EdgeInsets.only(left: 8, right: 2),
                            child: Icon(Icons.qr_code, color: Colors.black)),
                        Padding(
                            padding: EdgeInsets.only(left: 2, right: 8),
                            child: Icon(Icons.more_vert, color: Colors.black))
                      ])),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text("UID: ${Application.user.uid}")),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.redAccent),
                              borderRadius: BorderRadius.circular(4.0)),
                          child: Text(lv,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold))))
                ])
              ]),
              VEmptyView(24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _stateDisplay("积分", pts.toString()),
                _stateDisplay("威望", prestige.toString()),
                _stateDisplay("金钱", money.toString()),
                _stateDisplay("M值", mScore.toString())
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _stateDisplay("人气", popularity.toString()),
                _stateDisplay("好友", friends.toString()),
                _stateDisplay("回帖数", replies.toString()),
                _stateDisplay("主题帖", posts.toString())
              ]),
            ])));
  }

  _stateDisplay(String name, String value) {
    return Container(
        width: 72,
        height: 48,
        padding: EdgeInsets.all(4),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text(value), Text(name)]));
  }
}

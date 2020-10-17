import 'dart:ui';

import 'package:Ditiezu/Network/network.dart';
import 'package:Ditiezu/Route/routes.dart';
import 'package:Ditiezu/model/PostItem.dart';
import 'package:Ditiezu/pages/ViewThread/w_RateWindow.dart';
import "package:Ditiezu/utils/exts.dart";
import 'package:Ditiezu/utils/flutter_html/flutter_html.dart';
import 'package:Ditiezu/widgets/w_loading.dart';
import 'package:Ditiezu/widgets/w_radius_button.dart';
import 'package:Ditiezu/widgets/w_round_img.dart';
import 'package:Ditiezu/widgets/w_toast/w_toast.dart' hide Toast;
import 'package:flutter/cupertino.dart' hide Element;
import 'package:flutter/material.dart' hide Element;
import 'package:universal_html/html.dart' show Element;
import 'package:universal_html/parsing.dart';

class ViewThread extends StatefulWidget {
  ViewThread(this.tid, this.page);

  final tid;
  final page;

  @override
  _ViewThreadState createState() => _ViewThreadState();
}

class _ViewThreadState extends State<ViewThread> with TickerProviderStateMixin {
  int tid;
  String fid;
  String response;
  String messageText;
  String formhash;
  List<PostItem> posts = [];
  String title = "";

  int pages = 1;
  int currentPage;

  LoadingWidget lw;

  bool scoreEnabled;

  @override
  void initState() {
    tid = widget.tid;
    currentPage = widget.page;
    Future.delayed(Duration(seconds: 1), () {
      _contentResolver();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (messageText != null)
      return Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                  child: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onTap: () {
                    Routes.pop(context);
                  })),
          body: Stack(alignment: Alignment.center, children: [Positioned(top: 120, child: Text(messageText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)))]));
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
                child: Icon(Icons.arrow_back_ios, color: Colors.black),
                onTap: () {
                  Routes.pop(context);
                }),
            title: Text(title, style: TextStyle(color: Colors.black)),
            actions: [Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.search, color: Colors.black)), Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.more_vert, color: Colors.black))]),
        body: SafeArea(
            bottom: true,
            child: ListView.builder(
                itemBuilder: (BuildContext ctx, int index) {
                  if (index == posts.length)
                    return Container(
                        margin: EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.topCenter,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Offstage(
                              offstage: !(currentPage >= 2),
                              child: radiusButton(
                                  child: Icon(Icons.chevron_left, size: 18),
                                  action: () {
                                    currentPage--;
                                    _contentResolver();
                                  })),
                          Offstage(
                              offstage: !(currentPage >= 3),
                              child: radiusButton(
                                  child: Text((currentPage - 2).toString()),
                                  action: () {
                                    currentPage -= 2;
                                    _contentResolver();
                                  })),
                          Offstage(
                              offstage: !(currentPage >= 2),
                              child: radiusButton(
                                  child: Text((currentPage - 1).toString()),
                                  action: () {
                                    currentPage--;
                                    _contentResolver();
                                  })),
                          Offstage(offstage: pages == 1, child: radiusButton(child: Text((currentPage).toString()), action: () {}, colored: false)),
                          Offstage(
                              offstage: !(currentPage <= pages - 1),
                              child: radiusButton(
                                  child: Text((currentPage + 1).toString()),
                                  action: () {
                                    currentPage++;
                                    _contentResolver();
                                  })),
                          Offstage(
                              offstage: !(currentPage <= pages - 2),
                              child: radiusButton(
                                  child: Text((currentPage + 2).toString()),
                                  action: () {
                                    currentPage += 2;
                                    _contentResolver();
                                  })),
                          Offstage(
                              offstage: !(currentPage <= pages - 1),
                              child: radiusButton(
                                  child: Icon(Icons.chevron_right, size: 18),
                                  action: () {
                                    currentPage++;
                                    _contentResolver();
                                  })),
                        ]));

                  var data = posts[index];
                  return Container(
                      padding: EdgeInsets.all(16),
                      child: Column(children: [
                        Row(children: [
                          Padding(padding: EdgeInsets.only(right: 8), child: RoundImgWidget("http://ditiezu.com/uc_server/avatar.php?mod=avatar&uid=${data.authorUID}", 36)),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(data.authorName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.left),
                            Text(data.postTime, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey), textAlign: TextAlign.left)
                          ])
                        ]),
                        Container(
                            padding: EdgeInsets.only(left: 36, top: 12),
                            child: Column(children: [
                              Html(data: data.content),
                              Row(children: [
                                Padding(
                                    padding: EdgeInsets.all(7),
                                    child: GestureDetector(
                                        onTap: () {
                                          Routes.navigateTo(context, "/post", params: {"mode": "REPLY", "tid": tid.toString(), "fid": fid.toString(), "pid": data.pid.toString()});
                                        },
                                        child: Text("回复", style: TextStyle(color: Colors.grey[600])))),
                                Visibility(
                                    visible: scoreEnabled,
                                    child: Padding(
                                        padding: EdgeInsets.all(7),
                                        child: GestureDetector(
                                            onTap: () {
                                              _requestScore(data.pid);
                                            },
                                            child: Text("评分", style: TextStyle(color: Colors.grey[600]))))),
                              ])
                            ]))
                      ]));
                },
                itemCount: posts.length + 1)));
  }

  _contentResolver() {
    lw = LoadingWidget(context);
    try {
      () async {
        List<PostItem> tmpList = [];
        var response = await NetWork().get("http://www.ditiezu.com/forum.php?mod=viewthread&tid=$tid&page=$currentPage");
        var doc = parseHtmlDocument(response);
        if (doc.querySelector("#messagetext") != null) {
          messageText = doc.querySelector("#messagetext p").text;
          lw.onCancel();
          setState(() {});
          return;
        }
        fid = doc.querySelector("#dzsearchforumid").attributes["value"];
        formhash = doc.querySelector("[name=\"formhash\"]").attributes["value"];
        int index = 0;
        doc.querySelectorAll("ignore_js_op").forEach((e) {
          if (e.containsQuery("[id^='aimg_']")) {
            var img = new Element.img();
            var fileSrc = e.querySelector("[id^='aimg_']").attributes["file"];
            img.setAttribute("src", fileSrc.contains("http") ? fileSrc : "http://www.ditiezu.com/$fileSrc");
            e.replaceWith(img);
          }
        });
        doc.querySelectorAll("[file]").forEach((e) {
          e.setAttribute("src", e.attributes["file"]);
        });
        doc.querySelectorAll("[smilieid]").forEach((e) {
          e.setAttribute("src", "asset:" + e.attributes["src"].replaceFirst("image", "assets/images"));
        });
        scoreEnabled = doc.containsQuery("[onclick^=\"showWindow('rate'\"]");
        if (doc.containsQuery(".ratl")) {
          doc.querySelectorAll(".ratl a").forEach((a) {
            a.className = "noHighLight";
          });
          doc.querySelectorAll("[id^='rate_'] td").forEach((cell) {
            cell.style.verticalAlign = "middle";
          });
          doc.querySelectorAll("[id^='rate_'] img").forEach((img) {
            img.className = "score_avatar";
          });

          doc.querySelectorAll(".ratl i").forEach((i) {
            i.className = "noStyle";
          });

          doc.querySelectorAll("[onclick^='toggleRatelogCollapse(']").forEach((collapse) {
            collapse.remove();
          });
          doc.querySelectorAll(".ratc .xi2").forEach((all) {
            all.remove();
          });
          doc.querySelectorAll("[id^='post_rate']").forEach((pr) {
            pr.remove();
          });
        }
        title = doc.querySelector("#thread_subject").text;
        doc.querySelectorAll("table[id^='pid']").forEach((e) {
          if (e.querySelector(".avatar").text == "头像被屏蔽") {
            tmpList.add(PostItem("", e.querySelector(".authi .xw1").innerText, -1, "第" + ((currentPage - 1) * 15 + index + 1).toString() + "楼 - " + e.querySelector("[id^='authorposton']").innerText.substring(4), int.parse(e.id.substring(3))));
            return;
          }
          var src = e.querySelector(".avatar a").attributes["href"];
          tmpList.add(PostItem(
              e.querySelector(".pcb").querySelector("[id^='postmessage']").innerHtml +
                  (e.querySelector(".pcb").querySelector(".pattl") != null ? e.querySelector(".pcb").querySelector(".pattl").innerHtml : "") +
                  (e.querySelector(".locked") != null ? "<div class='locked'>抱歉，您需要登录才可以查看或下载附件</div>" : "") +
                  (e.querySelector("[id^='ratelog_']") != null ? "<p> </p><hr><div id='rateContainer'><table>" + e.querySelector(".ratl").innerHtml + "</table></div>" + e.querySelector(".ratc").innerHtml : ""),
              e.querySelector(".authi .xw1").innerText,
              int.parse(((src.indexOf("uid-") + 4 <= 0 || src.indexOf(".html") <= 0) ? 0 : src.substring(src.indexOf("uid-") + 4, src.indexOf(".html")))),
              "第" + ((currentPage - 1) * 15 + index + 1).toString() + "楼 - " + e.querySelector("[id^='authorposton']").innerText.substring(4),
              int.parse(e.id.substring(3))));
          index++;
        });
        if (doc.querySelector("#pgt .pg") != null) pages = int.parse(doc.querySelector("#pgt .pg").querySelectorAll("*:not(.nxt)").last.text.replaceFirst("... ", ""));

        posts = tmpList;
        setState(() {});
        lw.onCancel();
      }();
    } catch (e) {
      lw.onCancel();
    }
  }

  _requestScore(int pid) {
    () async {
      Animation<double> _fadeAnimation;
      AnimationController _fadeController;
      _fadeController = new AnimationController(vsync: this, duration: Duration(seconds: 1));
      _fadeAnimation = new Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(_fadeController);
      FToast ft = FToast()..init(context);
      var el = new FadeTransition(
          opacity: _fadeAnimation,
          child: new BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: RateWindow(
                  onFinish: () {
                    ft.remove();
                  },
                  tid: tid,
                  pid: pid,
                  formhash: formhash)));
      ft.showToast(
          child: el,
          positionedToastBuilder: (BuildContext context, Widget child) {
            return Positioned(bottom: 0, left: 0, right: 0, child: child);
          });
      _fadeController.forward();
    }();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

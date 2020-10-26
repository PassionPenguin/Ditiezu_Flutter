import 'dart:ui';

import 'package:Ditiezu/Widgets/InteractivePage.dart';
import 'package:flutter/cupertino.dart' hide Element;
import 'package:flutter/material.dart' hide Element;
import 'package:universal_html/html.dart' show Element;
import 'package:universal_html/parsing.dart';

import '../../Models/PostItem.dart';
import '../../Network/Network.dart';
import '../../Route/Routes.dart';
import "../../Utils/Exts.dart";
import '../../Utils/flutter_html/flutter_html.dart';
import '../../Widgets/w_radius_button.dart';
import '../../Widgets/w_round_img.dart';
import '../../Widgets/w_toast/w_toast.dart' hide Toast;
import 'w_RateWindow.dart';

class ViewThread extends StatefulWidget {
  ViewThread(this.tid, this.page);

  final tid;
  final page;

  @override
  _ViewThreadState createState() => _ViewThreadState();
}

class _ViewThreadState extends State<ViewThread> with TickerProviderStateMixin, InteractivePage {
  int tid;
  String fid;
  String response;
  String messageText;
  String formhash;
  List<PostItem> posts = [];
  String title = "";

  int pages = 1;
  int currentPage;

  bool scoreEnabled;

  @override
  void initState() {
    tid = widget.tid;
    currentPage = widget.page;
    super.bindIntractableWidgets(true, this);
    Future.delayed(Duration(seconds: 1), () {
      _contentResolver();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var el = Stack(children: [
      new Visibility(
          visible: !isMessageShowing,
          child: new FadeTransition(
              opacity: fadeAnimation["main"],
              child: SafeArea(
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
                                                () async {
                                                  await Routes.navigateTo(context, "/post", params: {"mode": "REPLY", "tid": tid.toString(), "fid": fid.toString(), "pid": data.pid.toString()});
                                                  _contentResolver();
                                                }();
                                              },
                                              child: Text("回复", style: TextStyle(color: Colors.grey[600])))),
                                      Visibility(
                                          visible: scoreEnabled,
                                          child: Padding(
                                              padding: EdgeInsets.all(7),
                                              child: GestureDetector(
                                                  onTap: () {
                                                    () async {
                                                      _requestScore(data.pid);
                                                      _contentResolver();
                                                    }();
                                                  },
                                                  child: Text("评分", style: TextStyle(color: Colors.grey[600]))))),
                                      Visibility(
                                          visible: data.editable,
                                          child: Padding(
                                              padding: EdgeInsets.all(7),
                                              child: GestureDetector(
                                                  onTap: () {
                                                    () async {
                                                      await Routes.navigateTo(context, "/post", params: {"mode": "EDIT", "tid": tid.toString(), "fid": fid.toString(), "pid": data.pid.toString()});
                                                      _contentResolver();
                                                    }();
                                                  },
                                                  child: Text("编辑", style: TextStyle(color: Colors.grey[600]))))),
                                    ])
                                  ]))
                            ]));
                      },
                      itemCount: posts.length + 1)))),
      new Visibility(visible: isLoading, child: new FadeTransition(opacity: fadeAnimation["loading"], child: Center(child: CircularProgressIndicator())))
    ]);
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
//            actions: [Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.search, color: Colors.black)), Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.more_vert, color: Colors.black))]
        ),
        body: el);
  }

  void _contentResolver() async {
    /**
     * [Future<Function>] _contentResolver
     * @return null
     * @purpose retrieve and process the thread page.
     */

    showLoading();
    try {
      posts = [];
      var response = await NetWork().get("http://www.ditiezu.com/forum.php?mod=viewthread&tid=$tid&page=$currentPage");
      var doc = parseHtmlDocument(response);
      if (doc.querySelector("#messagetext") != null) {
        showMessage(doc.querySelector("#messagetext p").text, Colors.red, Icons.clear);
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
          posts.add(PostItem("", e.querySelector(".authi .xw1").innerText, -1, "第" + ((currentPage - 1) * 15 + index + 1).toString() + "楼 - " + e.querySelector("[id^='authorposton']").innerText.substring(4), int.parse(e.id.substring(3)), false));
          return;
        }
        var src = e.querySelector(".avatar a").attributes["href"];
        posts.add(PostItem(
            e.querySelector(".pcb").querySelector("[id^='postmessage']").innerHtml +
                (e.querySelector(".pcb").querySelector(".pattl") != null ? e.querySelector(".pcb").querySelector(".pattl").innerHtml : "") +
                (e.querySelector(".locked") != null ? "<div class='locked'>抱歉，您需要登录才可以查看或下载附件</div>" : "") +
                (e.querySelector("[id^='ratelog_']") != null ? "<p> </p><hr><div id='rateContainer'><table>" + e.querySelector(".ratl").innerHtml + "</table></div>" + e.querySelector(".ratc").innerHtml : ""),
            e.querySelector(".authi .xw1").innerText,
            int.parse(((src.indexOf("uid-") + 4 <= 0 || src.indexOf(".html") <= 0) ? 0 : src.substring(src.indexOf("uid-") + 4, src.indexOf(".html")))),
            "第" + ((currentPage - 1) * 15 + index + 1).toString() + "楼 - " + e.querySelector("[id^='authorposton']").innerText.substring(4),
            int.parse(e.id.substring(3)),
            e.querySelector(".editp") != null));
        index++;
      });
      if (doc.querySelector("#pgt .pg") != null) pages = int.parse(doc.querySelector("#pgt .pg").querySelectorAll("*:not(.nxt)").last.text.replaceFirst("... ", ""));
      setState(() {});
      clearAnim();
    } catch (e) {
      clearAnim();
    }
  }

  void _requestScore(int pid) {
    /**
     * [Function] _requestScore(pid: int)
     * @param pid: int, the id of the thread
     * @return null
     * @purpose get the rating formdata, and show the rating window.
     */

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
                  _contentResolver();
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
  }
}

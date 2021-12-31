import 'dart:developer';
import 'dart:ui';

import 'package:ditiezu/io/network.dart';
import 'package:ditiezu/main.dart';
import 'package:ditiezu/models/post_item.dart';
import 'package:ditiezu/models/topic_item.dart';
import 'package:ditiezu/util/extract_link.dart';
import 'package:ditiezu/widget/avatar.dart';
import 'package:ditiezu/widget/extended_page.dart';
import 'package:ditiezu/widget/page_indicators.dart';
import 'package:flutter/cupertino.dart' hide Element;
import 'package:flutter/material.dart' hide Element;
import 'package:flutter_html/flutter_html.dart';
import 'package:universal_html/html.dart' show Element;
import 'package:universal_html/parsing.dart';

class ThreadPage extends StatefulWidget {
  ThreadPage(this.id, this.page);

  final int id;
  final int page;

  @override
  _ThreadPageState createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage>
    with TickerProviderStateMixin {
  late int id = widget.id;
  late Topic topic;

  // String formhash;
  List<PostItem> posts = [];
  String title = "";

  int pages = 0;
  late int currentPage = widget.page;

  // bool scoreEnabled;

  @override
  void initState() {
    currentPage = widget.page;
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var el = Stack(children: [
    //   Visibility(
    //       visible: !isMessageShowing,
    //       child: FadeTransition(
    //           opacity: fadeAnimation["main"],
    //           child:
    var el = SafeArea(
        bottom: true,
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext ctx, int index) {
              var data = posts[index];
              return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    Row(children: [
                      Avatar(uid: data.authorUID, width: 30),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.authorName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.left),
                            Text(data.postTime,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                                textAlign: TextAlign.left)
                          ])
                    ]),
                    Container(
                        padding: const EdgeInsets.only(left: 36, top: 12),
                        child: Column(children: [
                          Html(data: data.content),
                          Row(children: const [
                            // Padding(
                            //     padding: const EdgeInsets.all(7),
                            //     child: GestureDetector(
                            //         onTap: () {
                            //           () async {
                            //             // await Routes.navigateTo(
                            //             //     context, "/post",
                            //             //     params: {
                            //             //       "mode": "REPLY",
                            //             //       "tid": tid.toString(),
                            //             //       "fid": fid.toString(),
                            //             //       "pid":
                            //             //           data.pid.toString()
                            //             //     });
                            //             loadData();
                            //           }();
                            //         },
                            //         child: Text("回复",
                            //             style: TextStyle(
                            //                 color: Colors.grey[600])))),
                            // Visibility(
                            //     visible: scoreEnabled,
                            //     child: Padding(
                            //         padding: EdgeInsets.all(7),
                            //         child: GestureDetector(
                            //             onTap: () {
                            //               () async {
                            //                 // _requestScore(data.pid);
                            //                 loadData();
                            //               }();
                            //             },
                            //             child: Text("评分",
                            //                 style: TextStyle(
                            //                     color: Colors
                            //                         .grey[600]))))),
                            // Visibility(
                            //     visible: data.editable,
                            //     child: Padding(
                            //         padding: const EdgeInsets.all(7),
                            //         child: GestureDetector(
                            //             onTap: () {
                            //               () async {
                            //                 // await Routes.navigateTo(
                            //                 //     context, "/post",
                            //                 //     params: {
                            //                 //       "mode": "EDIT",
                            //                 //       "tid":
                            //                 //           id.toString(),
                            //                 //       "fid":
                            //                 //           topic.id.toString(),
                            //                 //       "pid": data.pid
                            //                 //           .toString()
                            //                 //     });
                            //                 loadData();
                            //               }();
                            //             },
                            //             child: Text("编辑",
                            //                 style: TextStyle(
                            //                     color: Colors.grey[600]))))),
                          ])
                        ]))
                  ]));
            },
            itemCount: posts.length));
    // )),
    // ]);
    var column = Column(children: [
      el,
      Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.topCenter,
          child: PageIndicators(
              pages: pages, currentPage: currentPage, callback: callback))
    ]);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
              child: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onTap: () {
                Navigator.of(context).pop();
              }),
          title: Text(title, style: const TextStyle(color: Colors.black)),
//            actions: [Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.search, color: Colors.black)), Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.more_vert, color: Colors.black))]
        ),
        body: SingleChildScrollView(child: column));
  }

  void loadData() async {
    /**
     * [Future<Function>] _contentResolver
     * @return null
     * @purpose retrieve and process the thread page.
     */
    var extractBin = ExtractLink();
    posts = [];
    var response = await NetWork()
        .get("forum.php?mod=viewthread&tid=$id&page=$currentPage");
    var document = parseHtmlDocument(response);
    if (document.querySelector("#messagetext") != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(document.querySelector("#messagetext p")!.text!),
      ));
      log(document.querySelector("#messagetext p")!.text!);
      return;
    }
    var topicEls = document.querySelectorAll("#pt a"),
        topicEl = topicEls[topicEls.length - 2];
    topic = extractBin.extractForumInformation(topicEl.attributes['href']!);
    // formhash = document.querySelector("[name=\"formhash\"]").attributes["value"];
    int index = 0;
    document.querySelectorAll("ignore_js_op").forEach((e) {
      var el = e.querySelector("[id^='aimg_']");
      if (el != null) {
        var img = Element.img();
        var fileSrc = el.attributes["file"]!;
        img.setAttribute(
            "src",
            fileSrc.contains("http")
                ? fileSrc
                : "http://www.ditiezu.com/$fileSrc");
        e.replaceWith(img);
      }
    });
    document.querySelectorAll("[file]").forEach((e) {
      e.setAttribute("src", e.attributes["file"]!);
    });
    document.querySelectorAll("[smilieid]").forEach((e) {
      e.setAttribute(
          "src",
          "asset:" +
              e.attributes["src"]!
                  .replaceFirst("static/image", "assets/images"));
    });
    // scoreEnabled = document.containsQuery("[onclick^=\"showWindow('rate'\"]");
    // if (document.querySelector(".ratl")!=null) {
    //   document.querySelectorAll(".ratl a").forEach((a) {
    //     a.className = "noHighLight";
    //   });
    //   document.querySelectorAll("[id^='rate_'] td").forEach((cell) {
    //     cell.style.verticalAlign = "middle";
    //   });
    //   document.querySelectorAll("[id^='rate_'] img").forEach((img) {
    //     img.className = "score_avatar";
    //   });
    //
    //   document.querySelectorAll(".ratl i").forEach((i) {
    //     i.className = "noStyle";
    //   });
    //
    //   document
    //       .querySelectorAll("[onclick^='toggleRatelogCollapse(']")
    //       .forEach((collapse) {
    //     collapse.remove();
    //   });
    //   document.querySelectorAll(".ratc .xi2").forEach((all) {
    //     all.remove();
    //   });
    //   document.querySelectorAll("[id^='post_rate']").forEach((pr) {
    //     pr.remove();
    //   });
    // }
    title = document.querySelector("#thread_subject")!.text!;
    document.querySelectorAll("table[id^='pid']").forEach((e) {
      if (e.querySelector(".avatar")!.text == "头像被屏蔽") {
        posts.add(PostItem(
            "",
            e.querySelector(".authi .xw1")!.text!,
            -1,
            "第" +
                ((currentPage - 1) * 15 + index + 1).toString() +
                "楼 - " +
                e.querySelector("[id^='authorposton']")!.text!.substring(4),
            int.parse(e.id.substring(3)),
            false));
        return;
      }
      var src = e.querySelector(".avatar a")!.attributes["href"];
      posts.add(PostItem(
          e
                  .querySelector(".pcb")!
                  .querySelector("[id^='postmessage']")!
                  .innerHtml! +
              (e.querySelector(".pcb")!.querySelector(".pattl") != null
                  ? e.querySelector(".pcb")!.querySelector(".pattl")!.innerHtml!
                  : "") +
              (e.querySelector(".locked") != null
                  ? "<div class='locked'>抱歉，您需要登录才可以查看或下载附件</div>"
                  : "") +
              (e.querySelector("[id^='ratelog_']") != null
                  ? "<p> </p><hr><div id='rateContainer'><table>" +
                      e.querySelector(".ratl")!.innerHtml! +
                      "</table></div>" +
                      e.querySelector(".ratc")!.innerHtml!
                  : ""),
          e.querySelector(".authi .xw1")!.innerText!,
          int.parse(
              ((src!.indexOf("uid-") + 4 <= 0 || src.indexOf(".html") <= 0)
                      ? 0
                      : src.substring(
                          src.indexOf("uid-") + 4, src.indexOf(".html")))
                  .toString()),
          "第" +
              ((currentPage - 1) * 15 + index + 1).toString() +
              "楼 - " +
              e.querySelector("[id^='authorposton']")!.innerText!.substring(4),
          int.parse(e.id.substring(3)),
          e.querySelector(".editp") != null));
      index++;
    });
    if (document.querySelector("#pgt .pg") != null && pages == 0) {
      var el = document
          .querySelector("#pgt .pg")!
          .querySelectorAll("*:not(.nxt)")
          .last;
      pages = extractBin.extractThreadInformation(el.attributes['href']!).page;
    } else if (pages == 0) {
      pages = 1;
    }
    setState(() {});
  }

  // void _requestScore(int pid) {
  //   /**
  //    * [Function] _requestScore(pid: int)
  //    * @param pid: int, the id of the thread
  //    * @return null
  //    * @purpose get the rating formdata, and show the rating window.
  //    */
  //
  //   Animation<double> _fadeAnimation;
  //   AnimationController _fadeController;
  //   _fadeController =
  //       new AnimationController(vsync: this, duration: Duration(seconds: 1));
  //   _fadeAnimation = new Tween(
  //     begin: 0.0,
  //     end: 1.0,
  //   ).animate(_fadeController);
  //   FToast ft = FToast()..init(context);
  //   var el = new FadeTransition(
  //       opacity: _fadeAnimation,
  //       child: new BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
  //           child: RateWindow(
  //               onFinish: () {
  //                 ft.remove();
  //                 _contentResolver();
  //               },
  //               tid: tid,
  //               pid: pid,
  //               formhash: formhash)));
  //   ft.showToast(
  //       child: el,
  //       positionedToastBuilder: (BuildContext context, Widget child) {
  //         return Positioned(bottom: 0, left: 0, right: 0, child: child);
  //       });
  //   _fadeController.forward();
  // }

  void callback(int v) {
    pages = v;
    loadData();
  }
}

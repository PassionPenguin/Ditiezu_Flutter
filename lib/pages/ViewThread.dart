import 'package:ditiezu_app/Network/network.dart';
import 'package:ditiezu_app/Route/routes.dart';
import 'package:ditiezu_app/model/PostItem.dart';
import 'package:ditiezu_app/utils/flutter_html/flutter_html.dart';
import 'package:ditiezu_app/widgets/w_loading.dart';
import 'package:ditiezu_app/widgets/w_round_img.dart';
import 'package:flutter/cupertino.dart' hide Element;
import 'package:flutter/material.dart' hide Element;
import 'package:universal_html/html.dart' show Element;
import 'package:universal_html/parsing.dart';

class ViewThread extends StatefulWidget {
  ViewThread(this.tid, this.page);

  final tid;
  final page;

  @override
  _ViewThreadState createState() => _ViewThreadState(tid, page);
}

class _ViewThreadState extends State<ViewThread> {
  _ViewThreadState(this.tid, this.currentPage);

  int tid;
  String response;
  List<PostItem> posts = [];
  String title = "";

  int pages = 1;
  int currentPage = 1;

  @override
  void initState() {
    _contentResolver();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            bottom: true,
            child: Stack(children: [
              Column(children: [
                AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: GestureDetector(
                        child: Icon(Icons.arrow_back_ios, color: Colors.black),
                        onTap: () {
                          Routes.pop(context);
                        }),
                    title: Text(title, style: TextStyle(color: Colors.black)),
                    actions: [
                      Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.search, color: Colors.black)),
                      Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.more_vert, color: Colors.black))
                    ],
                    flexibleSpace: Column()),
                Expanded(
                    child: ListView.builder(
                        itemBuilder: (BuildContext ctx, int index) {
                          if (index == posts.length) {
                            return Container(
                                margin: EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.topCenter,
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Offstage(
                                      offstage: !(currentPage >= 2),
                                      child: radiusButton(
                                          child: Icon(CupertinoIcons.back, size: 18),
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
                                          child: Icon(CupertinoIcons.forward, size: 18),
                                          action: () {
                                            currentPage++;
                                            _contentResolver();
                                          })),
                                ]));
                          }
                          var data = posts[index];
                          return Container(
                              padding: EdgeInsets.all(16),
                              child: Column(children: [
                                Row(children: [
                                  Padding(padding: EdgeInsets.only(right: 8), child: RoundImgWidget("http://ditiezu.com/uc_server/avatar.php?mod=avatar&uid=${data.authorUID}", 36)),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(data.authorName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.left),
                                    Text(data.postTime, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400), textAlign: TextAlign.left)
                                  ])
                                ]),
                                Container(padding: EdgeInsets.only(left: 36, top: 12), child: Html(data: data.content))
                              ]));
                        },
                        itemCount: posts.length + 1))
              ]),
            ])));
  }

  _contentResolver() {
    var lw = LoadingWidget(context);
        () async {
      List<PostItem> tmpList = [];
      var response = await NetWork(retrieveAsDesktopPage: true, gbkDecoding: true).get("http://www.ditiezu.com/forum.php?mod=viewthread&tid=$tid&page=$currentPage");
      var doc = parseHtmlDocument(response);
      int index = 0;
      doc.querySelectorAll("ignore_js_op").forEach((e) {
        if (e.querySelector("[id^='aimg_']") != null) {
          var img = new Element.img();
          img.setAttribute("src", e
              .querySelector("[id^='aimg_']")
              .attributes["file"]);
          e.replaceWith(img);
        }
      });
      doc.querySelectorAll("[file]").forEach((e) {
        e.setAttribute("src", e.attributes["file"]);
      });
      doc.querySelectorAll("[smilieid]").forEach((e) {
        e.setAttribute("src", "asset:" + e.attributes["src"].replaceFirst("image", "assets/images"));
      });
      title = doc
          .querySelector("#thread_subject")
          .text;
      doc.querySelectorAll("table[id^='pid']").forEach((e) {
        var src = e
            .querySelector(".avatar a")
            .attributes["href"];
        tmpList.add(PostItem(
            e
                .querySelector(".pcb")
                .querySelector("[id^='postmessage']")
                .innerHtml +
                (e.querySelector(".pcb").querySelector(".pattl") != null ? e
                    .querySelector(".pcb")
                    .querySelector(".pattl")
                    .innerHtml : "") +
                (e.querySelector(".locked") != null ? "<div class='locked'>抱歉，您需要登录才可以查看或下载附件</div>" : ""),
            // +                (e.querySelector("[id^='ratelog_']") != null ? e.querySelector("[id^='ratelog_']").innerHtml : ""),
            e
                .querySelector(".authi .xw1")
                .innerText,
            int.parse(((src.indexOf("uid-") + 4 <= 0 || src.indexOf(".html") <= 0) ? 0 : src.substring(src.indexOf("uid-") + 4, src.indexOf(".html")))),
            "第" + ((currentPage - 1) * 15 + index + 1).toString() + "楼 - " + e
                .querySelector("[id^='authorposton']")
                .innerText
                .substring(4),
            int.parse(e.id.substring(3))));
        index++;
      });
      if (doc.querySelector("#pgt .pg") != null) {
        pages = int.parse(doc
            .querySelector("#pgt .pg")
            .querySelectorAll("*:not(.nxt)")
            .last
            .text
            .replaceFirst("... ", ""));
      }

      posts = tmpList;
      try {
        lw.onCancel();
      } catch (e) {}
      setState(() {});
    }();
  }
}

Widget radiusButton({Widget child, GestureTapCallback action, bool colored = true}) {
  return GestureDetector(
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3),
          width: 30,
          height: 30,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), color: colored ? Color(0xFFEEEEEE) : Colors.transparent),
          child: Center(child: child)),
      onTap: action);
}

import 'package:ditiezu_app/Network/network.dart';
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

  int tid;
  int page;

  @override
  _ViewThreadState createState() => _ViewThreadState(tid, page);
}

class _ViewThreadState extends State<ViewThread> {
  _ViewThreadState(this.tid, this.page);

  int tid;
  int page;
  String response;
  List<PostItem> posts = [];
  String title = "";

  @override
  void initState() {
    var lw = LoadingWidget(context);
    () async {
      List<PostItem> tmpList = [];
      var response = await NetWork(retrieveAsDesktopPage: true, gbkDecoding: true).get("http://www.ditiezu.com/forum.php?mod=viewthread&tid=$tid&page=$page");
      var doc = parseHtmlDocument(response);
      int index = 0;
      doc.querySelectorAll("ignore_js_op").forEach((e) {
        if (e.querySelector("[id^='aimg_']") != null) {
          var img = new Element.img();
          img.setAttribute("src", e.querySelector("[id^='aimg_']").attributes["file"]);
          e.replaceWith(img);
        }
      });
      doc.querySelectorAll("[file]").forEach((e) {
        e.setAttribute("src", e.attributes["file"]);
      });
      title = doc.querySelector("#thread_subject").text;
      doc.querySelectorAll("table[id^='pid']").forEach((e) {
        var src = e.querySelector(".avatar a").attributes["href"];
        tmpList.add(PostItem(
            e.querySelector(".pcb").querySelector("[id^='postmessage']").innerHtml +
                (e.querySelector(".pcb").querySelector(".pattl") != null ? e.querySelector(".pcb").querySelector(".pattl").innerHtml : ""),
            // +                (e.querySelector("[id^='ratelog_']") != null ? e.querySelector("[id^='ratelog_']").innerHtml : ""),
            e.querySelector(".authi .xw1").innerText,
            int.parse(((src.indexOf("uid-") + 4 <= 0 || src.indexOf(".html") <= 0) ? 0 : src.substring(src.indexOf("uid-") + 4, src.indexOf(".html")))),
            "第" + ((page - 1) * 15 + index + 1).toString() + "楼 - " + e.querySelector("[id^='authorposton']").innerText.substring(4),
            int.parse(e.id.substring(3))));
        index++;
      });
      posts = tmpList;
      try {
        lw.onCancel();
      } catch (e) {}
      setState(() {});
    }();
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
                    leading: Icon(Icons.arrow_back_ios, color: Colors.black),
                    title: Text(title, style: TextStyle(color: Colors.black)),
                    actions: [
                      Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.search, color: Colors.black)),
                      Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.more_vert, color: Colors.black))
                    ],
                    flexibleSpace: Column()),
                Expanded(
                    child: ListView.builder(
                        itemBuilder: (BuildContext ctx, int index) {
                          var data = posts[index];
                          return Padding(
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
                        itemCount: posts.length))
              ]),
            ])));
  }
}

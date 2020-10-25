import 'package:Ditiezu/Widgets/InteractivePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/parsing.dart';

import '../../../Models/NotificationItem.dart';
import '../../../Network/Network.dart';
import 'NotificationListBuilder.dart';

class NotificationTab extends StatefulWidget {
  NotificationTab(this.ctx);

  final BuildContext ctx;

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> with TickerProviderStateMixin, InteractivePage {
  List<NotificationItem> notificationList = [];
  bool isRead = false;

  @override
  void initState() {
    super.bindIntractableWidgets(true, this);
    Future.delayed(Duration(milliseconds: 0)).then((e) {
      () async {
        _contentRetriever();
      }();
    });
    super.initState();
  }

  _contentRetriever() async {
    clearAnim();
    notificationList = [];
    setLoading();
    var response = await NetWork().get("http://www.ditiezu.com/home.php?mod=space&do=notice&isread=${isRead ? 1 : 0}");
    clearAnim();
    var doc = parseHtmlDocument(response);
    if (doc.querySelector(".emp") != null && doc.querySelector(".emp").text.contains("暂时没有新提醒")) {
      setAnim(false, true, "暂时没有新提醒", Colors.green, Icons.check);
      return;
    }
    var aBrackets = [];
    var imageUrls = [];
    var values = [];
    var descriptions = [];
    var times = [];
    var tids = [];
    var pages = [];
    doc.querySelectorAll("[notice]").forEach((it) {
      try {
        var quote;
        if (it.querySelector(".quote") != null) {
          quote = it.querySelector(".quote").text;
          it.querySelector(".quote").remove();
        }
        var aBracket = it.querySelector(".ntc_body a:last-child");
        aBrackets.add(aBracket);
        imageUrls.add(it.querySelector("img").attributes["src"].contains("systempm") ? "http://www.ditiezu.com/" + it.querySelector("img").attributes["src"] : it.querySelector("img").attributes["src"]);
        values.add(it.querySelector(".ntc_body").text);
        descriptions.add(quote);
        times.add(it.querySelector("dt span").text);
        setState(() {});
      } catch (ignored) {
        print(ignored);
      }
    });
    () async {
      setLoading();
      for (int i = 0; i < aBrackets.length; i++) {
        var tid = "-1";
        var page = "1";
        var aBracket = aBrackets[i];
        if (aBracket == null)
          tid = "-1";
        else {
          var href = aBracket.attributes["href"];
          if (href.contains("findpost")) {
            var result = await NetWork().retrieveRedirect(href);
            tid = result[0];
            page = result[1];
          } else if (href.contains("thread-")) {
            tid = href.substring(href.indexOf("thread-") + 7, href.indexOf("-", href.indexOf("thread-") + 7));
            page = "1";
          } else
            tid = "-1";
        }
        tids.add(tid);
        pages.add(page);
      }
      for (int i = 0; i < aBrackets.length; i++) notificationList.add(NotificationItem(imageUrl: imageUrls[i], value: values[i], description: descriptions[i], time: times[i], tid: tids[i], page: pages[i]));
      clearAnim();
    }();
  }

  Widget _contentResolver(BuildContext context) {
    var el = Stack(children: [
      new Visibility(visible: !isMessageShowing && !isLoading, child: new FadeTransition(opacity: fadeAnimation["main"], child: NotificationList(notificationList: notificationList))),
      new Visibility(visible: isLoading, child: new FadeTransition(opacity: fadeAnimation["loading"], child: Center(child: CircularProgressIndicator()))),
      new Visibility(visible: isMessageShowing && !isLoading, child: new FadeTransition(opacity: fadeAnimation["messaging"], child: Center(child: icnMessage())))
    ]);
    return SafeArea(
        top: true,
        child: Row(children: [
          Column(children: [
            GestureDetector(
                onTap: () {
                  if (isRead) {
                    isRead = false;
                    _contentRetriever();
                  }
                },
                child: Container(color: Colors.white, padding: EdgeInsets.only(top: 12, bottom: 4, left: 12, right: 12), child: Text("未\n读", style: TextStyle(fontSize: 16, color: isRead ? Colors.black : Colors.lightBlue[600])))),
            GestureDetector(
                onTap: () {
                  if (!isRead) {
                    isRead = true;
                    _contentRetriever();
                  }
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                    child: Container(color: Colors.white, padding: EdgeInsets.only(top: 4, bottom: 12, left: 12, right: 12), child: Text("已\n读", style: TextStyle(fontSize: 16, color: !isRead ? Colors.black : Colors.lightBlue[600]))))),
          ]),
          Expanded(child: el)
        ]));
  }

  @override
  Widget build(context) {
    return Scaffold(body: _contentResolver(context));
  }
}

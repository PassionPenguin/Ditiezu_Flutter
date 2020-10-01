import 'package:ditiezu_app/Network/network.dart';
import 'package:ditiezu_app/Route/routes.dart';
import 'package:ditiezu_app/model/NotificationItem.dart';
import 'package:ditiezu_app/widgets/v_empty_view.dart';
import 'package:ditiezu_app/widgets/w_loading.dart';
import 'package:ditiezu_app/widgets/w_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/parsing.dart';

class NotificationTab extends StatefulWidget {
  NotificationTab(this.ctx);

  final BuildContext ctx;

  @override
  _NotificationTabState createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  List<NotificationItem> notificationList = [];
  bool isRead = false;
  LoadingWidget lw;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((e) {
      () async {
        _contentRetriever();
      }();
    });
  }

  _contentRetriever() async {
    lw = LoadingWidget(context);
    notificationList = [];
    var response = await NetWork(gbkDecoding: true, retrieveAsDesktopPage: true).get("http://www.ditiezu.com/home.php?mod=space&do=notice&isread=${isRead ? 1 : 0}");
    var doc = parseHtmlDocument(response);
    if (doc.querySelector(".emp") != null && doc.querySelector(".emp").text.contains("暂时没有新提醒")) {
      lw.onCancel();
      Toast(context, "暂时没有新提醒", icon: Icons.sync);
      setState(() {});
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
        imageUrls
            .add(it.querySelector("img").attributes["src"].contains("systempm") ? "http://www.ditiezu.com/" + it.querySelector("img").attributes["src"] : it.querySelector("img").attributes["src"]);
        values.add(it.querySelector(".ntc_body").text);
        descriptions.add(quote);
        times.add(it.querySelector("dt span").text);
        setState(() {});
      } catch (ignored) {
        print(ignored);
      }
    });
    () async {
      for (int i = 0; i < aBrackets.length; i++) {
        var tid = "-1";
        var page = "1";
        var aBracket = aBrackets[i];
        if (aBracket == null)
          tid = "-1";
        else {
          var href = aBracket.attributes["href"];
          if (href.contains("findpost")) {
            var result = await NetWork(retrieveAsDesktopPage: true).retrieveRedirect(href);
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
      for (int i = 0; i < aBrackets.length; i++)
        notificationList.add(NotificationItem(imageUrl: imageUrls[i], value: values[i], description: descriptions[i], time: times[i], tid: tids[i], page: pages[i]));
      setState(() {});
    }();
    try {
      lw.onCancel();
    } catch (e) {}
  }

  Widget _contentResolver(BuildContext context) {
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
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(top: 12, bottom: 4, left: 12, right: 12),
                    child: Text("未\n读", style: TextStyle(fontSize: 16, color: isRead ? Colors.black : Colors.lightBlue[600])))),
            GestureDetector(
                onTap: () {
                  if (!isRead) {
                    isRead = true;
                    _contentRetriever();
                  }
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                    child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 4, bottom: 12, left: 12, right: 12),
                        child: Text("已\n读", style: TextStyle(fontSize: 16, color: !isRead ? Colors.black : Colors.lightBlue[600]))))),
          ]),
          Expanded(
              child: ListView.builder(
                  itemBuilder: (BuildContext buildContext, int index) {
                    var data = notificationList[index];
                    return SafeArea(
                        top: false,
                        bottom: false,
                        child: InkWell(
                            onTap: () {
                              Routes.navigateTo(context, Routes.thread, params: {'tid': data.tid.toString(), "page": data.page.toString()});
                            },
                            child: Padding(
                                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, right: 24.0, left: 24.0),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  Container(
                                      width: 40,
                                      height: 40,
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                          child: FadeInImage.assetNetwork(
                                            placeholder: 'assets/images/noavatar_middle.png',
                                            imageErrorBuilder: (BuildContext context, Object error, StackTrace stackTrace) {
                                              return Image.asset("assets/images/noavatar_middle.png");
                                            },
                                            image: data.imageUrl,
                                          ))),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(padding: EdgeInsets.only(left: 8), child: Text(data.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                      data.description != null ? Padding(padding: EdgeInsets.only(top: 4, left: 8), child: Text(data.description)) : VEmptyView(0),
                                      Padding(padding: EdgeInsets.only(top: 4, left: 8), child: Text(data.time, style: TextStyle(fontSize: 12))),
                                    ],
                                  )),
                                ]))));
                  },
                  itemCount: notificationList.length))
        ]));
  }

  @override
  Widget build(context) {
    return CupertinoPageScaffold(child: _contentResolver(context));
  }
}

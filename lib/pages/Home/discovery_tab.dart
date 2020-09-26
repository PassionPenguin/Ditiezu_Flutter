import 'package:ditiezu_app/Network/network.dart';
import 'package:ditiezu_app/model/ThreadItem.dart';
import 'package:ditiezu_app/widgets/w_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/parsing.dart';

class DiscoveryTab extends StatefulWidget {
  DiscoveryTab(this.ctx);

  BuildContext ctx;
  static const title = "Home";

  @override
  State<StatefulWidget> createState() => _DiscoveryTabState(ctx);
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  _DiscoveryTabState(this.ctx);

  BuildContext ctx;
  List<ThreadItem> homeList = [];
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

  void _contentRetriever() async {
    lw = LoadingWidget(ctx);
    var response = await NetWork(gbkDecoding: true).get("http://www.ditiezu.com/?mod=rss");
    if (homeList.isEmpty) {
      var document = parseXmlDocument(response);
      List<ThreadItem> tmpList = [];
      document.querySelectorAll("item").forEach((element) {
        if (element.querySelector("link").innerHtml.isNotEmpty) {
          var link = element.querySelector("link").innerHtml;
          var threadId = int.parse(link.substring(link.indexOf("tid=") + 4));
          tmpList.add(ThreadItem.rss(
              element.querySelector("title").innerHtml,
              element.querySelector("description").innerHtml.trim(),
              element.querySelector("author").innerHtml,
              element.querySelector("pubDate").innerHtml,
              element.querySelector("category").innerHtml,
              threadId,
              1,
              element.querySelector("enclosure") != null ? element.querySelector("enclosure").attributes["url"] : null,
              -1,
              0,
              0));
        }
      });
      tmpList.forEach((element) {
        homeList.add(element);
      });
      setState(() {});
      lw.onCancel();
    }
  }

  Widget _contentResolver(BuildContext context) {
    return SafeArea(
        top: true,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  var data = homeList[index];
                  var dt = DateFormat("dd MMM yyyy hh:mm:ss").parse(data.pubDate.substring(5, data.pubDate.length - 6)); // "dd MMM yyyy hh:mm:ss"
                  return SafeArea(
                    top: false,
                    bottom: false,
                    child: InkWell(
                        onTap: () {},
                        child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 24.0),
                            child: Row(children: [
                              Padding(padding: EdgeInsets.only(left: 24.0)),
                              if (data.enclosureUrl != null && data.enclosureUrl.trim() != "")
                                Row(children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(4), child: Image(image: NetworkImage(data.enclosureUrl), width: 120, height: 120, fit: BoxFit.cover)),
                                  Padding(padding: EdgeInsets.only(left: 16))
                                ]),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(padding: EdgeInsets.only(top: 8)),
                                  Text(
                                    data.threadTitle,
                                    style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 4)),
                                  Text("${data.authorName} ${data.badge} ${dt.month}-${dt.day}", style: TextStyle(fontSize: 12)),
                                  if (data.threadContent.trim().isNotEmpty)
                                    Column(children: [Padding(padding: EdgeInsets.only(top: 6)), Text(data.threadContent, style: TextStyle(fontSize: 15), maxLines: 3)]),
                                  Padding(padding: EdgeInsets.only(top: 8)),
                                ],
                              )),
                            ]))),
                  );
                },
                childCount: homeList.length,
              ),
            )
          ],
        ));
  }

  @override
  Widget build(context) {
    return CupertinoPageScaffold(child: _contentResolver(context));
  }
}

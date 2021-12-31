import 'package:ditiezu/io/network.dart';
import 'package:ditiezu/models/thread_item.dart';
import 'package:ditiezu/util/extract_link.dart';
import 'package:ditiezu/widget/avatar.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/parsing.dart';

class TrendingPosts extends StatefulWidget {
  const TrendingPosts({Key? key}) : super(key: key);

  @override
  _TrendingPostsState createState() => _TrendingPostsState();
}

class _TrendingPostsState extends State<TrendingPosts> {
  List<ThreadItem> list = [];

  void loadData() async {
    var response = await NetWork().get("");
    var document = parseHtmlDocument(response);
    List<ThreadItem> tmpList = [];
    var extractBin = ExtractLink();
    document.querySelectorAll("#portal_block_55_content li").forEach((element) {
      var titleEl = element.querySelector(".blackvs")!,
          authorEl = element.querySelector("code a")!;
      tmpList.add(ThreadItem(
          threadTitle: titleEl.text!,
          badge: element.querySelector(".comiis_mr5")!.text!,
          thread:
              extractBin.extractThreadInformation(titleEl.attributes['href']!),
          author: extractBin.extractUserInformation(
              authorEl.attributes['href']!, authorEl.text!)));
    });
    setState(() {
      list = tmpList;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var content =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Trending Posts",
          style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: itemBuilder,
        itemCount: list.length,
      )
    ]);
    return Container(
        child: content,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16));
  }

  Widget itemBuilder(BuildContext ctx, int id) {
    var item = list[id];
    var firstColumn = Row(children: [
      SizedBox(
          width: 75,
          child: Text(
            "[${item.badge}]",
            style: const TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          )),
      Expanded(
          child: Text(
        item.threadTitle,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      )),
    ]);
    return Column(children: [
      firstColumn,
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Avatar(uid: item.author.id),
        const SizedBox(width: 8),
        Text(item.author.name)
      ]),
      const SizedBox(height: 16)
    ]);
  }
}

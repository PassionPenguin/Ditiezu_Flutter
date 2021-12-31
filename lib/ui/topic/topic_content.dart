import 'package:ditiezu/main.dart';
import 'package:ditiezu/models/thread_item.dart';
import 'package:ditiezu/ui/thread/thread_page.dart';
import 'package:ditiezu/widget/extended_page.dart';
import 'package:flutter/material.dart';

class TopicContent extends StatelessWidget {
  const TopicContent({Key? key, required this.list}) : super(key: key);
  final List<ThreadItem> list;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        var item = list[index];
        TextSpan tp = () {
          var c = <InlineSpan>[
            TextSpan(
                text: item.badge,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepOrangeAccent)),
            const WidgetSpan(child: SizedBox(width: 8)),
            TextSpan(
                text: item.threadTitle,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const WidgetSpan(child: SizedBox(width: 8)),
          ];
          if (item.isNew) {
            c.add(WidgetSpan(
                child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child:
                        Image.asset("assets/images/icn_new.png", height: 14))));
          }
          if (item.isHot) {
            c.add(WidgetSpan(
                child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child:
                        Image.asset("assets/images/icn_hot.png", height: 14))));
          }
          if (item.withImage) {
            c.add(WidgetSpan(
                child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Image.asset("assets/images/icn_image.png",
                        height: 14))));
          }
          if (item.withAttachment) {
            c.add(WidgetSpan(
                child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Image.asset("assets/images/icn_attachment.png",
                        height: 14))));
          }
          return TextSpan(children: c);
        }();
        return InkWell(
            onTap: () => callback(context, item.thread.id, item.thread.page),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 8)),
                    Text.rich(tp),
                    const Padding(padding: EdgeInsets.only(top: 8)),
                    Text.rich(
                        TextSpan(children: <InlineSpan>[
                          TextSpan(text: item.author.name),
                          const TextSpan(text: " "),
                          TextSpan(
                              text: item.pubDate,
                              style: TextStyle(
                                  color: item.timeIsToday
                                      ? Colors.orange[800]
                                      : Colors.grey[800]))
                        ]),
                        style: const TextStyle(fontSize: 12)),
                    const Padding(padding: EdgeInsets.only(top: 8)),
                    Row(children: [
                      Text(item.views.toString() + " 查看",
                          style: const TextStyle(color: Colors.black45)),
                      const Padding(padding: EdgeInsets.only(left: 8)),
                      Text(item.replies.toString() + " 回复",
                          style: const TextStyle(color: Colors.black45))
                    ])
                  ],
                )));
      },
      itemCount: list.length,
    );
  }

  void callback(BuildContext context, int id, int _page) {
    var page = ExtendedPage(child: ThreadPage(id, _page));
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

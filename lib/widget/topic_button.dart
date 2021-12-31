import 'package:ditiezu/models/topic_item.dart';
import 'package:ditiezu/ui/topic/topic_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'extended_page.dart';

class TopicButton extends StatelessWidget {
  final TopicItem item;
  final GestureTapCallback action;

  const TopicButton({Key? key, required this.item, required this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var icon = SizedBox(
        child: SvgPicture.asset("assets/images/topic_icons/${item.topicIcon}"),
        width: 24,
        height: 24);
    return SizedBox(
        child: TextButton.icon(
            icon: icon,
            label: Text(
              item.topicName,
              style: const TextStyle(color: Colors.black),
            ),
            onPressed: () => callback(context)),
        height: 36);
  }

  void callback(BuildContext context) {
    var page = ExtendedPage(
        child: TopicPage(
      item: item,
    ));
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

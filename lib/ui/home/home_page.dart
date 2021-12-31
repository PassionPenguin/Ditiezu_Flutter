import 'package:ditiezu/data/topics.dart';
import 'package:ditiezu/widget/extended_icon_button.dart';
import 'package:ditiezu/widget/search_box.dart';
import 'package:ditiezu/widget/topic_button.dart';
import 'package:ditiezu/widget/user_avatar.dart';
import 'package:flutter/material.dart';
import 'trending_posts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 32),
      child: Column(children: [
        buildToolbarWidget(),
        Expanded(
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  buildRecommendedTopics(context),
                  const TrendingPosts(),
                  buildTopicList()
                ])))
      ]),
      constraints: const BoxConstraints(maxWidth: 640),
    );
  }

  Widget buildToolbarWidget() {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          const UserAvatar(),
          Expanded(child: SearchBox()),
          ExtendedIconButton(
            icon: Icons.chat_bubble_outline,
            onPressed: () {},
          ),
          ExtendedIconButton(
            icon: Icons.add,
            onPressed: () {},
          )
        ]));
  }

  Widget buildTopicList() {
    var list = topicList.map((e) {
      return TopicButton(
        item: e,
        action: () {},
      );
    }).toList();
    double cardWidth = MediaQuery.of(context).size.width / 3;
    double cardHeight = 48;
    var grid = GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        crossAxisCount: 3,
        childAspectRatio: cardWidth / cardHeight,
        children: list);
    return Column(children: [
      const Text("All Topics",
          style: TextStyle(
              color: Colors.deepOrangeAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      grid
    ]);
  }

  Widget buildRecommendedTopics(BuildContext ctx) {
    var list = recommendedTopicList.map((e) {
      return TopicButton(
        item: e,
        action: () {},
      );
    }).toList();
    double cardWidth = MediaQuery.of(context).size.width / 3;
    double cardHeight = 48;
    var grid = GridView.count(
        padding: EdgeInsets.zero,
        crossAxisCount: 3,
        childAspectRatio: cardWidth / cardHeight,
        children: list);
    return Container(
        height: 160, padding: const EdgeInsets.all(8), child: grid);
  }
}

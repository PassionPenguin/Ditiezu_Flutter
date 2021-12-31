import 'dart:math';

import 'package:ditiezu/io/network.dart';
import 'package:ditiezu/models/tag.dart';
import 'package:ditiezu/models/thread_item.dart';
import 'package:ditiezu/models/topic_item.dart';
import 'package:ditiezu/util/extract_link.dart';
import 'package:ditiezu/util/generate_palette.dart';
import 'package:ditiezu/widget/page_indicators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:universal_html/parsing.dart';

import 'topic_content.dart';

class TopicPage extends StatefulWidget {
  const TopicPage({Key? key, required this.item}) : super(key: key);

  final TopicItem item;

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  late TopicItem item = widget.item;
  List<Tag> tags = [];
  List<ThreadItem> list = [];
  int pages = 0;
  int currentPage = 1;
  int currentTag = -1;

  void loadData() async {
    var suffixes = [];
    if (currentTag != -1) {
      suffixes.addAll(["filter=typeid", "typeid=$currentTag"]);
    }
    var response = await NetWork()
        .get("forum-${item.topicID}-$currentPage.html?" + suffixes.join("&"));
    var document = parseHtmlDocument(response);
    List<ThreadItem> tmpList = [];
    List<Tag> tmpTags = [];
    var extractBin = ExtractLink();

    if (document.querySelector("#pgt .pg") != null && pages == 0) {
      var el = document
          .querySelector("#pgt .pg")!
          .querySelectorAll("*:not(.nxt)")
          .last;
      pages = extractBin.extractForumInformation(el.attributes['href']!).page;
    } else if (pages == 0) {
      pages = 1;
    }
    document
        .querySelectorAll("#thread_types li:not(#ttp_all):not(.xw1) a")
        .forEach((e) {
      var hrf = e.attributes["href"]!;
      hrf = hrf.substring(hrf.indexOf("typeid=") + 7);
      int id;
      if (hrf.contains("&")) {
        id = int.parse(hrf.substring(0, hrf.indexOf("&")));
      } else {
        id = int.parse(hrf);
      }
      tmpTags.add(Tag(e.text!, id));
    });
    document.querySelectorAll("[id^='normalthread_']").forEach((element) {
      var author = element.querySelectorAll(".by cite a")[0];
      var authorLink = author.attributes["href"]!;
      var title = element.querySelector(".xst")!,
          titleHref = title.attributes["href"]!;
      var thread = extractBin.extractThreadInformation(titleHref);
      tmpList.add(ThreadItem(
          threadTitle: title.innerHtml!,
          author: extractBin.extractUserInformation(authorLink, author.text!),
          pubDate: element.querySelector(".by em")!.text!,
          badge: element.querySelector("em")!.text!,
          thread: thread,
          views: int.parse(element.querySelector(".num em")!.text!),
          replies: int.parse(element.querySelector(".num a")!.text!),
          isHot:
              element.querySelector("[src='comiis_xy/folder_hot.gif']") != null,
          isNew: element.querySelector(".by em")!.querySelector(".xi1") != null,
          withImage: element.querySelector("[alt='attach_img']") != null,
          withAttachment: element.querySelector("[alt='attachment']") != null,
          timeIsToday:
              element.querySelector(".by em")!.querySelector(".xi1") != null));
    });
    setState(() {
      list = tmpList;
      tags = tmpTags;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var content = Column(children: [
      TopicContent(
        list: list,
      ),
      PageIndicators(
          pages: pages, currentPage: currentPage, callback: changePage)
    ]);
    return Container(
      child: SingleChildScrollView(
          child: Column(children: [
        TopicToolbar(item: item, tags: tags, callback: changeTag),
        const SizedBox(height: 16),
        content
      ])),
      constraints: const BoxConstraints(maxWidth: 640),
    );
  }

  void changePage(v) {
    currentPage = v;
    loadData();
  }

  void changeTag(v) {
    currentTag = v.id;
    loadData();
  }
}

class TopicToolbar extends StatelessWidget {
  TopicToolbar(
      {Key? key,
      required this.item,
      required this.tags,
      required this.callback})
      : super(key: key);

  final TopicItem item;
  final List<Tag> tags;
  late final AssetImage? image = item.backgroundName != ""
      ? AssetImage("assets/images/topic_images/${item.backgroundName}.jpeg")
      : null;
  final ValueChanged<Tag> callback;

  @override
  Widget build(BuildContext context) {
    return buildContainer();
  }

  Widget buildContainer() {
    return FutureBuilder<PaletteGenerator>(
        future: image != null ? generatePalette(image!) : null, // async work
        builder:
            (BuildContext context, AsyncSnapshot<PaletteGenerator> snapshot) {
          Color color = Colors.teal;
          switch (snapshot.connectionState) {
            default:
              if (!snapshot.hasError) {
                color = snapshot.data?.dominantColor?.color ?? Colors.teal;
              }
          }
          var decoration = image != null
              ? DecorationImage(
                  scale: 1.2,
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6), BlendMode.srcOver),
                  image: image!)
              : null;
          return Container(
            height: 256,
            padding: const EdgeInsets.only(left: 32, right: 32, top: 64),
            decoration: BoxDecoration(color: color, image: decoration),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [buildDescriptionRow(context), buildTopicTags()]),
          );
        });
  }

  Widget buildTopicTags() {
    var view = ListView.builder(
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) return buildTag(Tag("全部", -1));
        return buildTag(tags[index - 1]);
      },
      itemCount: tags.length + 1,
    );
    return SizedBox(height: 48, child: view);
  }

  Widget buildTag(Tag tag) {
    return TextButton(
      child: Text(
        tag.name,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () {
        callback(tag);
      },
    );
  }

  Widget buildDescriptionRow(BuildContext context) {
    var image = SvgPicture.asset("assets/images/topic_icons/${item.topicIcon}",
        width: 64);
    var title = Text(item.topicName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900)),
        desc = Text(item.topicDescription,
            maxLines: 3,
            softWrap: true,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600));
    var textColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [title, desc]);
    return Row(children: [
      image,
      const SizedBox(width: 16),
      SizedBox(
          width: min(MediaQuery.of(context).size.width, 720) - 224,
          child: textColumn)
    ]);
  }
}

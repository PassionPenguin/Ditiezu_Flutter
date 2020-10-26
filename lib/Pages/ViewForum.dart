import 'package:Ditiezu/Widgets/InteractivePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/parsing.dart';

import '../Data/CategoryData.dart';
import '../Models/CategoryItem.dart';
import '../Models/SelectItem.dart';
import '../Models/ThreadItem.dart';
import '../Network/Network.dart';
import '../Route/Routes.dart';
import '../Utils/dropdown_menu/dropdown_menu.dart';
import '../Widgets/w_radius_button.dart';

class ViewForum extends StatefulWidget {
  ViewForum(this.fid);

  final fid;

  @override
  _ViewForumState createState() => _ViewForumState();
}

class _ViewForumState extends State<ViewForum> with TickerProviderStateMixin, InteractivePage {
  int currentPage = 1;
  int pages = 1;
  int fid;
  CategoryItem cur;

  List<SelectItem> _typesList = [SelectItem.full(name: "全部", isSelected: true, id: -1)];
  SelectItem selectedType = SelectItem.full(name: "全部", isSelected: true, id: -1);

  bool typeID = false;
  String filter = "";
  List<String> filtersParam = [
    "",
    'digest&digest=1',
    'recommend&recommend=1',
    'specialtype&specialtype=poll',
    'specialtype&specialtype=activity',
    'author&orderby=dateline',
    'reply&orderby=replies',
    'reply&orderby=views',
    'lastpost&orderby=lastposts',
    'heat&orderby=heats',
    'typeid'
  ];
  List<SelectItem> _filtersList = [SelectItem("默认"), SelectItem("精选"), SelectItem("推介"), SelectItem("投票"), SelectItem("活动"), SelectItem("发帖时间"), SelectItem("回复"), SelectItem("查看"), SelectItem("最后回复"), SelectItem("热度"), SelectItem("分区")];
  List<ThreadItem> forumList = [];
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    fid = widget.fid;
    cur = categoryList.firstWhere((element) => element.categoryID == fid);
    super.bindIntractableWidgets(true, this);
    Future.delayed(Duration(seconds: 1), () {
      _contentResolver();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var el = Stack(children: [
      new Visibility(
          visible: !isMessageShowing,
          child: new FadeTransition(
              opacity: fadeAnimation["main"],
              child: DefaultDropdownMenuController(
                child: Column(children: [
                  AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: GestureDetector(
                          child: Icon(Icons.arrow_back_ios, color: Colors.black),
                          onTap: () {
                            Routes.pop(context);
                          }),
                      title: Text(cur.categoryName, style: TextStyle(color: Colors.black)),
//                      actions: [Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.search, color: Colors.black)), Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.more_vert, color: Colors.black))],
                      flexibleSpace: Column()),
                  DropdownHeader(
                      onTap: (int index) {
                        DropdownMenuController controller = DefaultDropdownMenuController.of(globalKey.currentContext);
                        controller.show(index);
                      },
                      titles: [selectedType.name, _filtersList[filtersParam.indexOf(filter)].name]),
                  Expanded(
                      child: Stack(key: globalKey, children: [
                    ListView.builder(
                        itemBuilder: (BuildContext ctx, int index) {
                          if (index == forumList.length)
                            return Container(
                                margin: EdgeInsets.symmetric(vertical: 16),
                                alignment: Alignment.topCenter,
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Offstage(
                                      offstage: !(currentPage >= 2),
                                      child: radiusButton(
                                          child: Icon(Icons.chevron_left, size: 18),
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
                                          child: Icon(Icons.chevron_right, size: 18),
                                          action: () {
                                            currentPage++;
                                            _contentResolver();
                                          })),
                                ]));
                          else if (index >= forumList.length) return Container();
                          var data = forumList[index];
                          TextSpan tp = () {
                            var c = <InlineSpan>[];
                            c.add(TextSpan(text: data.badge, style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w400, color: Colors.lightBlue)));
                            c.add(TextSpan(text: data.threadTitle, style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w600, color: Colors.black87)));
                            if (data.isNew) c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_new.png", height: 14))));
                            if (data.isHot) c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_hot.png", height: 14))));
                            if (data.withImage) c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_image.png", height: 14))));
                            if (data.withAttachment) c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_attachment.png", height: 14))));
                            return TextSpan(children: c);
                          }();
                          return SafeArea(
                              top: false,
                              bottom: false,
                              child: InkWell(
                                  onTap: () {
                                    Routes.navigateTo(context, Routes.thread, params: {'tid': data.threadID.toString(), "page": data.threadPage.toString()});
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 24.0),
                                      child: Row(children: [
                                        Padding(padding: EdgeInsets.only(left: 24.0)),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(padding: EdgeInsets.only(top: 8)),
                                            Text.rich(tp),
                                            Padding(padding: EdgeInsets.only(top: 8)),
                                            Text.rich(TextSpan(children: List<InlineSpan>()..add(TextSpan(text: data.authorName))..add(TextSpan(text: " "))..add(TextSpan(text: data.pubDate, style: TextStyle(color: data.timeIsToday ? Colors.orange[800] : Colors.grey[800])))),
                                                style: TextStyle(fontSize: 12)),
                                            if (data.threadContent.trim().isNotEmpty) Column(children: [Padding(padding: EdgeInsets.only(top: 4)), Text(data.threadContent, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400), maxLines: 3)]),
                                            Padding(padding: EdgeInsets.only(top: 8)),
                                            Row(children: [
                                              Text(data.views.toString() + " 查看", style: TextStyle(color: Colors.black45)),
                                              Padding(padding: EdgeInsets.only(left: 8)),
                                              Text(data.replies.toString() + " 回复", style: TextStyle(color: Colors.black45))
                                            ])
                                          ],
                                        )),
                                      ]))));
                        },
                        itemCount: forumList.length + 1),
                    Positioned(
                        right: 24,
                        bottom: 24,
                        child: FloatingActionButton(
                            onPressed: () {
                              () async {
                                await Routes.navigateTo(context, "/post", params: {"mode": "NEW", "fid": fid.toString()});
                                _contentResolver();
                              }();
                            },
                            child: Icon(Icons.add))),
                    DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 10,
                        //  activeIndex: activeIndex,
                        menus: [
                          new DropdownMenuBuilder(
                              builder: (BuildContext context) {
                                return new DropdownListMenu(
                                  selectedIndex: _typesList.indexOf(selectedType),
                                  data: _typesList,
                                  itemBuilder: buildCheckItem,
                                  callback: (index) {
                                    typeID = true;
                                    if (filter == "") filter = "typeid";
                                    selectedType = _typesList[index];
                                    currentPage = 1;
                                    _contentResolver();
                                    setState(() {});
                                  },
                                );
                              },
                              height: kDropdownMenuItemHeight * _typesList.length),
                          new DropdownMenuBuilder(
                              builder: (BuildContext context) {
                                return new DropdownListMenu(
                                    selectedIndex: filtersParam.indexOf(filter),
                                    data: _filtersList,
                                    itemBuilder: buildCheckItem,
                                    callback: (index) {
                                      filter = filtersParam[index];
                                      currentPage = 1;
                                      _contentResolver();
                                      setState(() {});
                                    });
                              },
                              height: kDropdownMenuItemHeight * _filtersList.length),
                        ])
                  ]))
                ]),
              ))),
      new Visibility(visible: isLoading, child: new FadeTransition(opacity: fadeAnimation["loading"], child: Center(child: CircularProgressIndicator())))
    ]);

    return Scaffold(body: SafeArea(bottom: true, child: el));
  }

  String queryParams() {
    /**
     * [Function] queryParams
     * @return (String) query parameters
     * @purpose generate the query parameters
     */

    var params = "";
    if (typeID && selectedType.id != -1) {
      params += "&typeid=${selectedType.id}";
      if (filter != "typeid")
        params += "&filter=$filter";
      else
        params += "&filter=typeid";
    } else if (filter != "") params = "&filter=$filter";
    return params;
  }

  void _contentResolver() async {
    /**
     * [Future<Function>] queryParams
     * @return null
     * @purpose retrieve and process the threads list.
     */

    /* [API] Forum Threads List Retriever
      @method GET
      @url http://www.ditiezu.com/forum.php?mod=forumdisplay&fid=[fid]&page=[page](+ [options])
      @expected
        Succeed: HTML document with threads list
     */
    var response = await NetWork().get("http://www.ditiezu.com/forum.php?mod=forumdisplay&fid=$fid&page=$currentPage" + queryParams());
    var document = parseHtmlDocument(response);
    if (document.querySelector("#pgt .pg") != null)
      pages = int.parse(document.querySelector("#pgt .pg").querySelectorAll("*:not(.nxt)").last.text.replaceFirst("... ", ""));
    else
      pages = 1;
    forumList = [];
    document.querySelectorAll("#thread_types li:not(#ttp_all):not(.xw1) a").forEach((e) {
      var hrf = e.attributes["href"];
      hrf = hrf.substring(hrf.indexOf("typeid=") + 7);
      int id;
      if (hrf.contains("&"))
        id = int.parse(hrf.substring(0, hrf.indexOf("&")));
      else
        id = int.parse(hrf);
      _typesList.add(SelectItem.full(name: e.text, isSelected: false, id: id));
    });
    document.querySelectorAll("[id^='normalthread_']").forEach((element) {
      var author = element.querySelectorAll(".by cite a")[0];
      var authorLink = author.attributes["href"];
      var title = element.querySelector(".xst");
      var targetId = title.attributes["href"].contains(".html")
          ? int.parse(title.attributes["href"].substring(30, title.attributes["href"].lastIndexOf(".html") - 4))
          : int.parse(title.attributes["href"].substring(52, title.attributes["href"].indexOf("&", 52)));
      forumList.add(ThreadItem(
          title.innerHtml,
          "",
          author.innerHtml,
          element.querySelector(".by em").text,
          element.querySelector("em").innerText,
          targetId,
          1,
          int.parse(authorLink.substring(authorLink.indexOf("uid-") + 4, authorLink.indexOf(".html"))),
          int.parse(element.querySelector(".num em").innerHtml),
          int.parse(element.querySelector(".num a").innerHtml),
          element.querySelector("[src='comiis_xy/folder_hot.gif']") != null,
          element.querySelector(".by em").querySelector(".xi1") != null,
          element.querySelector("[alt='attach_img']") != null,
          element.querySelector("[alt='attachment']") != null,
          element.querySelector(".by em").querySelector(".xi1") != null));
    });
    setState(() {});
    clearAnim();
  }
}

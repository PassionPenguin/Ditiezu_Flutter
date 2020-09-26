import 'package:ditiezu_app/Network/network.dart';
import 'package:ditiezu_app/Route/routes.dart';
import 'package:ditiezu_app/data/CategoryData.dart';
import 'package:ditiezu_app/model/CategoryItem.dart';
import 'package:ditiezu_app/model/SelectItem.dart';
import 'package:ditiezu_app/model/ThreadItem.dart';
import 'package:ditiezu_app/widgets/w_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gzx_dropdown_menu/gzx_dropdown_menu.dart';
import 'package:universal_html/parsing.dart';

class ViewForum extends StatefulWidget {
  ViewForum(this.fid);

  int fid;

  @override
  _ViewForumState createState() => _ViewForumState(fid);
}

class _ViewForumState extends State<ViewForum> {
  _ViewForumState(this.fid) {
    cur = categoryList.firstWhere((element) => element.categoryID == fid);
  }

  int fid;
  CategoryItem cur;

  List<SelectItem> _typesList = [SelectItem(name: "全部", isSelected: true, id: -1)];
  SelectItem selectedType = SelectItem(name: "全部", isSelected: true, id: -1);

  // ["typeid", "author", "reply", "lastpost", "heat"];
  String filter = "unknown";

  // ["dateline", "replies", "views", "lastposts", "heats"];
  String order;

  List<ThreadItem> forumList = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 0), () async {
      _contentRetriever();
    });
  }

  @override
  Widget build(BuildContext context) {
    var _stackKey = GlobalKey();
    var _dropdownMenuController = GZXDropdownMenuController();
    return Scaffold(
        body: SafeArea(
            bottom: true,
            child: Stack(children: [
              Column(children: [
                AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Icon(Icons.arrow_back_ios, color: Colors.black),
                    title: Text(cur.categoryName, style: TextStyle(color: Colors.black)),
                    actions: [
                      Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.search, color: Colors.black)),
                      Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.more_vert, color: Colors.black))
                    ],
                    flexibleSpace: Column()),
                GZXDropDownHeader(
                  items: [
                    GZXDropDownHeaderItem(selectedType.name),
                    GZXDropDownHeaderItem("时间"),
                    GZXDropDownHeaderItem("排序"),
                  ],
                  stackKey: _stackKey,
                  controller: _dropdownMenuController,
                  height: 40,
                  borderWidth: 1,
                  borderColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                  dropDownStyle: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColor,
                  ),
                  iconSize: 20,
                  iconColor: Color(0xFFafada7),
                  iconDropDownColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                    child: ListView.builder(
                        itemBuilder: (BuildContext ctx, int index) {
                          var data = forumList[index];
                          var dt = data.pubDate;
                          TextSpan tp = () {
                            var c = <InlineSpan>[];
                            c.add(TextSpan(text: data.badge, style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w400, color: Colors.lightBlue)));
                            c.add(TextSpan(text: data.threadTitle, style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w600, color: Colors.black87)));
                            if (data.isNew) c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_new.png", height: 14))));
                            if (data.isHot) c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_hot.png", height: 14))));
                            if (data.withImage) c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_image.png", height: 14))));
                            if (data.withAttachment)
                              c.add(WidgetSpan(child: Padding(padding: EdgeInsets.only(left: 4, bottom: 3), child: Image.asset("assets/images/icn_attachment.png", height: 14))));
                            return TextSpan(children: c);
                          }();
                          return SafeArea(
                              top: false,
                              bottom: false,
                              child: InkWell(
                                  // Make it splash on Android. It would happen automatically if this
                                  // was a real card but this is just a demo. Skip the splash on iOS.
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
                                            Text("${data.authorName} $dt", style: TextStyle(fontSize: 12)),
                                            if (data.threadContent.trim().isNotEmpty)
                                              Column(children: [
                                                Padding(padding: EdgeInsets.only(top: 4)),
                                                Text(data.threadContent, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400), maxLines: 3)
                                              ]),
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
                        itemCount: forumList.length))
              ]),
              GZXDropDownMenu(
                controller: _dropdownMenuController,
                animationMilliseconds: 500,
                dropdownMenuChanging: (isShow, index) {
                  setState(() {});
                },
                dropdownMenuChanged: (isShow, index) {
                  setState(() {});
                },
                menus: [
                  GZXDropdownMenuBuilder(
                      dropDownHeight: 40 * 8.0,
                      dropDownWidget: _buildConditionListWidget(_typesList, (value) {
                        selectedType = value;
                        _dropdownMenuController.hide();
                        setState(() {});
                      })),
                ],
              )
            ])));
  }

  String queryParams() {
    var params = "";
    switch (filter) {
      case "unknown":
        params = "";
        break;
      case "typeid":
        params = selectedType.id != -1 ? "&filter=typeid&typeid=${selectedType.id}&orderby=dateline" : "";
        break;
      default:
        params = "";
        break;
    }
    return params;
  }

  void _contentRetriever() async {
    var lw = LoadingWidget(context);
    var response = await NetWork(retrieveAsDesktopPage: true, gbkDecoding: true).get("http://www.ditiezu.com/forum.php?mod=forumdisplay&fid=$fid" + queryParams());
    var document = parseHtmlDocument(response);
    List<ThreadItem> tmpList = [];
    document.querySelectorAll("[id^='normalthread_']").forEach((element) {
      var author = element.querySelectorAll(".by cite a")[0];
      var authorLink = author.attributes["href"];
      var title = element.querySelector(".xst");
      var targetId = title.attributes["href"].contains(".html")
          ? int.parse(title.attributes["href"].substring(30, title.attributes["href"].lastIndexOf(".html") - 4))
          : int.parse(title.attributes["href"].substring(52, title.attributes["href"].indexOf("&", 52)));
      tmpList.add(ThreadItem(
          title.innerHtml,
          "",
          author.innerHtml,
          element.querySelector(".by em").text,
          element.querySelector("em").innerText,
          targetId,
          1,
          int.parse(element.querySelector(".num a").innerHtml),
          int.parse(element.querySelector(".num em").innerHtml),
          int.parse(authorLink.substring(authorLink.indexOf("uid-") + 4, authorLink.indexOf(".html"))),
          element.querySelector("[src='comiis_xy/folder_hot.gif']") != null,
          element.querySelector(".by em").querySelector(".xi1") != null,
          element.querySelector("[alt='attach_img']") != null,
          element.querySelector("[alt='attachment']") != null));
    });
    forumList = tmpList;
    lw.onCancel();
    setState(() {});
  }

  Widget _buildConditionListWidget(List<SelectItem> items, void itemOnTap(SelectItem sortCondition)) {
    return ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: items.length,
        separatorBuilder: (BuildContext context, int index) => Divider(height: 1.0),
        itemBuilder: (BuildContext context, int index) {
          SelectItem el = items[index];
          return GestureDetector(
            onTap: () {
              for (var value in items) {
                value.isSelected = false;
              }
              el.isSelected = true;
              itemOnTap(el);
            },
            child: Container(
//            color: Colors.blue,
              height: 40,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Text(
                      el.name,
                      style: TextStyle(
                        color: el.isSelected ? Theme.of(context).primaryColor : Colors.black,
                      ),
                    ),
                  ),
                  el.isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                          size: 16,
                        )
                      : SizedBox(),
                  SizedBox(
                    width: 16,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:Ditiezu/Network/NetworkImage.dart' as NetI;
import 'package:Ditiezu/Network/network.dart';
import 'package:Ditiezu/app.dart';
import 'package:Ditiezu/data/EmoticonsData.dart';
import 'package:Ditiezu/widgets/w_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:Ditiezu/Route/routes.dart";
import 'package:flutter/rendering.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' show Document;
import 'package:universal_html/parsing.dart';

class Post extends StatefulWidget {
  String mode;

  int fid; // NEW
  int tid; // REPLY
  int pid; // EDIT

  Post.post({this.fid}) {
    mode = "NEW";
  }

  Post.reply({this.tid, this.fid, this.pid}) {
    mode = "REPLY";
  }

  Post.edit({this.pid, this.tid, this.fid}) {
    mode = "EDIT";
  }

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  TextEditingController controller = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  Document oriDoc;

  String formHash;
  String attachHash;
  List<List<Widget>> emoticonsItem = [];
  int emoticonsIndex = 0;
  bool emoticonStage = true;
  bool imageStage = false;

  List<String> typeNameList = [""];
  List<String> typeValueList = [""];
  var currentTypeValue = "";

  List<String> attachUrlList = [];
  List<String> attachIDList = [];

  bool keyboardState = false;
  String submitState = "FALSE";

  bool withSignature = true;
  bool withPerm = false;
  bool withRewards = false;

  String perm = "";
  String rewards = "";
  String rewardsTimes = "";
  String rewardsMaxTimes = "";
  String rewardsOdds = "";

  _queryParams() {
    switch (widget.mode) {
      case "NEW":
        return "newthread&fid=${widget.fid}";
      case "REPLY":
        return "reply&tid=${widget.tid}&fid=${widget.fid}&repquote=${widget.pid}";
      default:
        return "edit&pid=${widget.pid}";
    }
  }

  _onSubmit() async {
    // VALIDATE
    submitState = "ONPOST";

    var url = "";
    var formData = "message=" +
        UrlEncode().encode(controller.text) +
        "&formhash=$formHash";
    if (widget.mode != "SIGHTML" && withSignature) formData += "&usesig=1";
    attachIDList.forEach((it) {
      formData += "&attachnew[$it][description]=";
    });
    switch (widget.mode) {
      case "NEW":
        url =
            "http://www.ditiezu.com/forum.php?mod=post&action=newthread&fid=${widget.fid}&extra=&topicsubmit=yes&inajax=1";
        formData += "&typeid=$currentTypeValue";
        formData += "&subject=" + UrlEncode().encode(subjectController.text);
        if (withPerm) formData += "&readperm=$perm";
        if (withRewards) {
          formData += "&replycredit_extcredits=$rewards";
          formData += "&replycredit_times=$rewardsTimes";
          formData += "&replycredit_membertimes=$rewardsMaxTimes";
          formData += "&replycredit_random=$rewardsOdds";
        }
        break;
      case "EDIT":
        url =
            "http://www.ditiezu.com/forum.php?mod=post&action=edit&extra=&editsubmit=yes&inajax=1";
        formData += "&pid=${widget.pid}&tid=${widget.tid}";
        break;
      case "REPLY":
        url =
            "http://www.ditiezu.com/forum.php?mod=post&action=reply&tid=${widget.tid}&replysubmit=yes&inajax=1";
        formData +=
            "&reppid=${widget.pid}&reppost=${widget.pid}&noticeauthor=" +
                UrlEncode().encode(oriDoc
                    .querySelector("[name='noticeauthor']")
                    .attributes['value']);
        formData += "&noticetrimstr=" +
            UrlEncode().encode(oriDoc
                .querySelector("[name='noticetrimstr']")
                .attributes['value']);
        formData += "&noticeauthormsg=" +
            UrlEncode().encode(oriDoc
                .querySelector("[name='noticeauthormsg']")
                .attributes['value']);
        break;
      default:
        url = "http://www.ditiezu.com/home.php?mod=spacecp&ac=profile";
        break;
    }

    var str = await NetWork().post(url, formData);
    var response = str.substring(str.indexOf("', '", str.indexOf("handle")) + 4,
        str.indexOf("'", str.indexOf("', '", str.indexOf("handle")) + 4));
    if (str != "") {
      if (str.contains("succeed") || str.contains("success")) {
        Toast(context, response);
        Future.delayed(Duration(seconds: 2), () {
          Routes.pop(context);
        });
        if (widget.mode == "SIGHTML")
          Application.sp.setString("SIGHTML_VALUE", controller.text);
      } else if (str.contains('error')) {
        submitState = "TRUE";
        Toast(context, response, accentColor: Colors.red, icon: Icons.close);
      }
    }
  }

  _loadAttaches() async {
    attachUrlList = [];
    attachIDList = [];
    var doc = parseHtmlDocument(parseXmlDocument(await NetWork().get(
            "http://www.ditiezu.com/forum.php?mod=ajax&action=imagelist&inajax=1&ajaxtarget=imgattachlist"))
        .nodes[0]
        .text);
    doc.querySelectorAll("[id^='imageattach']").forEach((e) {
      attachUrlList.add(e.querySelector("img").attributes["src"]);
      attachIDList.add(e.id.substring(11));
    });
    setState(() {});
  }

  @override
  void initState() {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        keyboardState = visible;
        setState(() {});
      },
    );
    () async {
      try {
        emoticonsItem = emoticonItemsData.map((e) {
          return e.list.map((i) {
            return GestureDetector(
                onTap: () {
                  _setText("", i.insert, "");
                },
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                        "assets/images/smiley/${e.src}/${i.src}.gif")));
          }).toList();
        }).toList();
      } catch (e) {}
      oriDoc = parseHtmlDocument(await NetWork().get(
          "http://www.ditiezu.com/forum.php?mod=post&action=${_queryParams()}"));
      if (oriDoc.querySelector("#messagetext") != null) {
        Toast(context, oriDoc.querySelector("#messagetext").text,
            accentColor: Colors.red, icon: Icons.close);
        if (oriDoc.querySelector("#messagelogin") != null) {
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
          cookieJar.deleteAll();
          Routes.navigateTo(context, "/login");
        }
      }
      formHash = oriDoc.querySelector("[name='formhash']").attributes["value"];
      attachHash = oriDoc.querySelector("[name='hash']").attributes["value"];
      switch (widget.mode) {
        case "NEW":
          typeNameList = [];
          typeValueList = [];
          oriDoc.querySelectorAll("#typeid option").forEach((it) {
            typeNameList.add(it.text);
            typeValueList.add(it.attributes["value"]);
          });
          currentTypeValue = typeValueList[0];
      }
      await _loadAttaches();
      setState(() {});
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getEmoticonListHeight() {
      var tmp = emoticonsItem[emoticonsIndex].length ~/
          (MediaQuery.of(context).size.width ~/ 48) *
          48.0;
      return tmp > 240.0 ? 240.0 : tmp;
    }

    return Scaffold(
        body: SafeArea(
            bottom: true,
            child: Stack(children: [
              Column(children: [
                AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: GestureDetector(
                        child: Icon(Icons.arrow_back_ios, color: Colors.black),
                        onTap: () {
                          Routes.pop(context);
                        }),
                    title: Text(
                        [
                          "发帖",
                          "回复",
                          "编辑"
                        ][["NEW", "REPLY", "EDIT"].indexOf(widget.mode)],
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      GestureDetector(
                          onTap: () {
                            Application.sp
                                .setString(
                                    "POST_${widget.mode}", controller.text)
                                .whenComplete(() => Toast(context, "已成功保存"));
                          },
                          child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Icon(Icons.save, color: Colors.black))),
                      CupertinoButton(
                          onPressed: () {
                            if (submitState == "TRUE") _onSubmit();
                          },
                          child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Icon(Icons.send, color: Colors.black)))
                    ]),
                Expanded(
                    child: Column(children: [
                  Expanded(
                      child: Column(children: [
                    Offstage(
                        offstage: !(widget.mode == "NEW"),
                        child: Row(children: [
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButton(
                                value: typeNameList[
                                    typeValueList.indexOf(currentTypeValue)],
                                items: typeNameList.map((e) {
                                  return DropdownMenuItem(
                                      child: Text(e), value: e);
                                }).toList(),
                                onChanged: (value) {
                                  currentTypeValue = typeValueList[
                                      typeNameList.indexOf(value)];
                                  setState(() {});
                                },
                              )),
                          Expanded(
                              child: CupertinoTextField(
                            decoration: null,
                            controller: subjectController,
                          ))
                        ])),
                    Expanded(
                        child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(16),
                            child: CupertinoTextField(
                              onChanged: (str) {
                                print(submitState);
                                if (str.length >= 10 && submitState == "FALSE")
                                  submitState = "TRUE";
                              },
                              controller: controller,
                              decoration: null,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                            )))
                  ])),
                  Column(children: [
                    Container(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _formatButton(Icon(Icons.format_bold),
                                () => _setText("[b]", "", "[/b]")),
                            _formatButton(Icon(Icons.format_italic),
                                () => _setText("[i]", "", "[/i]")),
                            _formatButton(Icon(Icons.format_underlined),
                                () => _setText("[u]", "", "[/u]")),
                            _formatButton(Icon(Icons.format_strikethrough),
                                () => _setText("[s]", "", "[/s]")),
                            _formatButton(Icon(Icons.color_lens), () {}),
                            _formatButton(
                                Icon(Icons.insert_link),
                                () => _setText(
                                    "[link=", "\$LINKHERE", "][/link]")),
                            _formatButton(Icon(Icons.insert_emoticon), () {
                              // IF EMOTICON WINDOW STAGE IS TRUE && KEYBOARD IS DOWN then CLOSE THE EMOTICON WINDOW
                              if (emoticonStage && !keyboardState)
                                emoticonStage = false;
                              else
                                emoticonStage = true;
                              FocusScope.of(context).unfocus();
                              if (imageStage) imageStage = false;
                            }),
                            _formatButton(Icon(Icons.insert_photo), () {
                              if (imageStage && !keyboardState)
                                imageStage = false;
                              else
                                imageStage = true;
                              FocusScope.of(context).unfocus();
                              if (emoticonStage) emoticonStage = false;
                            }),
                          ],
                        )),
                    Offstage(
                        offstage: !emoticonStage || keyboardState,
                        child: Column(children: [
                          Container(
                              padding: EdgeInsets.only(
                                  top: 4, right: 16, bottom: 8, left: 16),
                              height: _getEmoticonListHeight() + 20,
                              child: GridView.count(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width ~/ 48,
                                  childAspectRatio: 1,
                                  children: emoticonsItem[emoticonsIndex])),
                          Container(
                              height: 40,
                              padding: EdgeInsets.only(bottom: 6),
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _formatButton(
                                        Text(emoticonItemsData[0].name,
                                            style: emoticonsIndex == 0
                                                ? TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold)
                                                : TextStyle()), () {
                                      emoticonsIndex = 0;
                                    }),
                                    _formatButton(
                                        Text(emoticonItemsData[1].name,
                                            style: emoticonsIndex == 1
                                                ? TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold)
                                                : TextStyle()), () {
                                      emoticonsIndex = 1;
                                    }),
                                    _formatButton(
                                        Text(emoticonItemsData[2].name,
                                            style: emoticonsIndex == 2
                                                ? TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold)
                                                : TextStyle()), () {
                                      emoticonsIndex = 2;
                                    }),
                                    _formatButton(
                                        Text(emoticonItemsData[3].name,
                                            style: emoticonsIndex == 3
                                                ? TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold)
                                                : TextStyle()), () {
                                      emoticonsIndex = 3;
                                    }),
                                  ]))
                        ])),
                    Offstage(
                        offstage: !imageStage || keyboardState,
                        child: Column(children: [
                          Container(
                              padding: EdgeInsets.only(
                                  top: 4, right: 16, bottom: 8, left: 16),
                              height: 128 + 40.0,
                              child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          _setText(
                                              "[attachimg]",
                                              attachIDList[index],
                                              "[/attachimg]");
                                        },
                                        child: Image(
                                            image: NetI.NetworkImage(
                                                "http://www.ditiezu.com/" +
                                                    attachUrlList[index]),
                                            width: 128,
                                            height: 128));
                                  },
                                  itemCount: attachUrlList.length,
                                  scrollDirection: Axis.horizontal)),
                          Container(
                              height: 40,
                              padding: EdgeInsets.only(bottom: 6),
                              child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _formatButton(Text("选择图片"), () {
                                      () async {
                                        await Routes.navigateTo(
                                            context, "/uploader",
                                            params: {
                                              "hash": attachHash,
                                              "uid": Application.user.uid
                                                  .toString(),
                                              "fid": widget.fid.toString()
                                            });
                                        _loadAttaches();
                                        setState(() {});
                                      }();
                                    }),
                                  ]))
                        ]))
                  ])
                ]))
              ])
            ])));
  }

  _setText(before, value, after) {
    var text = controller.text;
    var tStart =
        controller.selection.start == -1 ? 0 : controller.selection.start;
    var tEnd = controller.selection.end == -1 ? 0 : controller.selection.end;
    if (tStart == tEnd) {
      controller.text = text.substring(0, tStart) +
          before +
          value +
          after +
          text.substring(tStart, text.length);
    }
    var a = text.substring(0, tStart) + before;
    var b = value != "" ? value : text.substring(tStart, tEnd);
    var c = after + text.substring(tEnd, text.length);
    controller.text = a + b + c;
    controller.selection =
        TextSelection(baseOffset: a.length, extentOffset: a.length + b.length);
  }

  _formatButton(Widget widget, Function action) {
    return GestureDetector(
        onTap: () {
          action();
          setState(() {});
        },
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: widget));
  }
}

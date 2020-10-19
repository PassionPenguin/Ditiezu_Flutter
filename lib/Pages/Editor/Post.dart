import 'dart:io';

import 'package:Ditiezu/Widgets/w_iconMessage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' show Document;
import 'package:universal_html/parsing.dart';

import '../../Data/EmoticonsData.dart';
import '../../Network/Network.dart';
import '../../Network/NetworkImage.dart' as NetI;
import "../../Route/Routes.dart";
import '../../app.dart';

class Post extends StatefulWidget {
  final String mode;

  final int fid; // NEW
  final int tid; // REPLY
  final int pid; // EDIT

  Post.post({this.fid, this.tid, this.pid, this.mode = "NEW"});

  Post.reply({this.tid, this.fid, this.pid, this.mode = "REPLY"});

  Post.edit({this.pid, this.tid, this.fid, this.mode = "EDIT"});

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> with TickerProviderStateMixin {
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

  bool isLoading = true;
  bool isMessageShowing = false;
  String message = "";
  IconData icon = Icons.check;
  Color color = Colors.green;

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
    var formData = "message=" + UrlEncode().encode(controller.text) + "&formhash=$formHash";
    if (widget.mode != "SIGHTML" && withSignature) formData += "&usesig=1";
    attachIDList.forEach((it) {
      formData += "&attachnew[$it][description]=";
    });
    switch (widget.mode) {
      case "NEW":
        url = "http://www.ditiezu.com/forum.php?mod=post&action=newthread&fid=${widget.fid}&extra=&topicsubmit=yes&inajax=1";
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
        url = "http://www.ditiezu.com/forum.php?mod=post&action=edit&extra=&editsubmit=yes&inajax=1";
        formData += "&pid=${widget.pid}&tid=${widget.tid}";
        break;
      case "REPLY":
        url = "http://www.ditiezu.com/forum.php?mod=post&action=reply&tid=${widget.tid}&replysubmit=yes&inajax=1";
        formData += "&reppid=${widget.pid}&reppost=${widget.pid}&noticeauthor=" + UrlEncode().encode(oriDoc.querySelector("[name='noticeauthor']").attributes['value']);
        formData += "&noticetrimstr=" + UrlEncode().encode(oriDoc.querySelector("[name='noticetrimstr']").attributes['value']);
        formData += "&noticeauthormsg=" + UrlEncode().encode(oriDoc.querySelector("[name='noticeauthormsg']").attributes['value']);
        break;
      default:
        url = "http://www.ditiezu.com/home.php?mod=spacecp&ac=profile";
        break;
    }

    setState(() {
      isLoading = true;
    });
    var str = await NetWork().post(url, formData);
    setState(() {
      isLoading = false;
    });
    var response = str.substring(str.indexOf("', '", str.indexOf("handle")) + 4, str.indexOf("'", str.indexOf("', '", str.indexOf("handle")) + 4));
    if (str != "") {
      if (str.contains("succeed") || str.contains("success")) {
        Application.sp.setString("POST_${widget.mode}", "");
        setState(() {
          isMessageShowing = true;
          message = response;
          icon = Icons.check;
          color = Colors.green;
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isMessageShowing = false;
            });
          });
        });
        Future.delayed(Duration(seconds: 3), () {
          Routes.pop(context);
        });
        if (widget.mode == "SIGHTML") Application.sp.setString("SIGHTML_VALUE", controller.text);
      } else if (str.contains('error')) {
        submitState = "TRUE";
        setState(() {
          isMessageShowing = true;
          message = response;
          icon = Icons.close;
          color = Colors.red;
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isMessageShowing = false;
            });
          });
        });
      }
    }
  }

  _loadAttaches() async {
    attachUrlList = [];
    attachIDList = [];
    setState(() {
      isLoading = true;
    });
    var doc = parseHtmlDocument(parseXmlDocument(await NetWork().get("http://www.ditiezu.com/forum.php?mod=ajax&action=imagelist&inajax=1&ajaxtarget=imgattachlist")).nodes[0].text);
    doc.querySelectorAll("[id^='imageattach']").forEach((e) {
      attachUrlList.add(e.querySelector("img").attributes["src"]);
      attachIDList.add(e.id.substring(11));
    });
    setState(() {
      isMessageShowing = true;
      isLoading = false;
      message = "已成功获取附件列表";
      icon = Icons.check;
      color = Colors.green;
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isMessageShowing = false;
        });
      });
    });
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
                child: Padding(padding: EdgeInsets.all(8), child: Image.asset("assets/images/smiley/${e.src}/${i.src}.gif")));
          }).toList();
        }).toList();
      } catch (e) {}
      setState(() {
        isLoading = true;
      });
      oriDoc = parseHtmlDocument(await NetWork().get("http://www.ditiezu.com/forum.php?mod=post&action=${_queryParams()}"));
      setState(() {
        isLoading = false;
      });
      if (oriDoc.querySelector("#messagetext") != null) {
        setState(() {
          isMessageShowing = true;
          message = oriDoc.querySelector("#messagetext").text;
          icon = Icons.close;
          color = Colors.red;
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isMessageShowing = false;
            });
          });
        });
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
      var savedValue = Application.sp.getString("POST_${widget.mode}");
      if (savedValue != null) controller.text = savedValue;
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getEmoticonListHeight() {
      var tmp = emoticonsItem[emoticonsIndex].length ~/ (MediaQuery.of(context).size.width ~/ 48) * 48.0;
      return tmp > 240.0 ? 240.0 : tmp;
    }

    Map<String, Animation<double>> _fadeAnimation = {};
    Map<String, AnimationController> _fadeController = {};
    _fadeController["main"] = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeController["loading"] = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeController["messaging"] = new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _fadeAnimation["main"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController["main"]);
    _fadeAnimation["loading"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController["loading"]);
    _fadeAnimation["messaging"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController["messaging"]);
    var el = Stack(children: [
      new Visibility(
          visible: !isMessageShowing && !isLoading,
          child: new FadeTransition(
              opacity: _fadeAnimation["main"],
              child: Column(children: [
                AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: GestureDetector(
                        child: Icon(Icons.arrow_back_ios, color: Colors.black),
                        onTap: () {
                          Routes.pop(context);
                        }),
                    title: Text(["发帖", "回复", "编辑"][["NEW", "REPLY", "EDIT"].indexOf(widget.mode)], style: TextStyle(color: Colors.black)),
                    actions: [
                      GestureDetector(
                          onTap: () {
                            Application.sp.setString("POST_${widget.mode}", controller.text)
                              ..then((value) => {
                                    setState(() {
                                      isMessageShowing = true;
                                      message = "已保存";
                                      icon = Icons.save;
                                      color = Colors.green;
                                      Future.delayed(Duration(seconds: 1), () {
                                        setState(() {
                                          isMessageShowing = false;
                                        });
                                      });
                                    })
                                  })
                              ..catchError((error) {
                                setState(() {
                                  isMessageShowing = true;
                                  isLoading = false;
                                  message = error;
                                  icon = Icons.bug_report;
                                  color = Colors.red;
                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      isMessageShowing = false;
                                    });
                                  });
                                });
                              });
                          },
                          child: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.save, color: Colors.black))),
                      MaterialButton(
                          onPressed: () {
                            if (submitState == "TRUE")
                              _onSubmit();
                            else
                              setState(() {
                                isMessageShowing = true;
                                message = "紫薯布丁红薯布丁～";
                                icon = Icons.edit;
                                color = Colors.red;
                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() {
                                    isMessageShowing = false;
                                  });
                                });
                              });
                          },
                          child: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Icon(Icons.send, color: Colors.black)))
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
                                value: typeNameList[typeValueList.indexOf(currentTypeValue)],
                                items: typeNameList.map((e) {
                                  return DropdownMenuItem(child: Text(e), value: e);
                                }).toList(),
                                onChanged: (value) {
                                  currentTypeValue = typeValueList[typeNameList.indexOf(value)];
                                  setState(() {});
                                },
                              )),
                          Expanded(
                              child: TextField(
                            decoration: null,
                            controller: subjectController,
                          ))
                        ])),
                    Expanded(
                        child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(16),
                            child: TextField(
                              onChanged: (str) {
                                if (str.length >= 10 && submitState == "FALSE") submitState = "TRUE";
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
                            _formatButton(Icon(Icons.format_bold), () => _setText("[b]", "", "[/b]")),
                            _formatButton(Icon(Icons.format_italic), () => _setText("[i]", "", "[/i]")),
                            _formatButton(Icon(Icons.format_underlined), () => _setText("[u]", "", "[/u]")),
                            _formatButton(Icon(Icons.format_strikethrough), () => _setText("[s]", "", "[/s]")),
                            _formatButton(Icon(Icons.color_lens), () {}),
                            _formatButton(Icon(Icons.insert_link), () => _setText("[link=", "\$LINKHERE", "][/link]")),
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
                              padding: EdgeInsets.only(top: 4, right: 16, bottom: 8, left: 16),
                              height: _getEmoticonListHeight() + 20,
                              child: GridView.count(crossAxisCount: MediaQuery.of(context).size.width ~/ 48, childAspectRatio: 1, children: emoticonsItem[emoticonsIndex])),
                          Container(
                              height: 40,
                              padding: EdgeInsets.only(bottom: 6),
                              child: ListView(scrollDirection: Axis.horizontal, children: [
                                _formatButton(Text(emoticonItemsData[0].name, style: emoticonsIndex == 0 ? TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold) : TextStyle()), () {
                                  emoticonsIndex = 0;
                                }),
                                _formatButton(Text(emoticonItemsData[1].name, style: emoticonsIndex == 1 ? TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold) : TextStyle()), () {
                                  emoticonsIndex = 1;
                                }),
                                _formatButton(Text(emoticonItemsData[2].name, style: emoticonsIndex == 2 ? TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold) : TextStyle()), () {
                                  emoticonsIndex = 2;
                                }),
                                _formatButton(Text(emoticonItemsData[3].name, style: emoticonsIndex == 3 ? TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold) : TextStyle()), () {
                                  emoticonsIndex = 3;
                                }),
                              ]))
                        ])),
                    Offstage(
                        offstage: !imageStage || keyboardState,
                        child: Column(children: [
                          Container(
                              padding: EdgeInsets.only(top: 4, right: 16, bottom: 8, left: 16),
                              height: 128 + 40.0,
                              child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          _setText("[attachimg]", attachIDList[index], "[/attachimg]");
                                        },
                                        child: Image(image: NetI.NetworkImage("http://www.ditiezu.com/" + attachUrlList[index]), width: 128, height: 128));
                                  },
                                  itemCount: attachUrlList.length,
                                  scrollDirection: Axis.horizontal)),
                          Container(
                              height: 40,
                              padding: EdgeInsets.only(bottom: 6),
                              child: ListView(scrollDirection: Axis.horizontal, children: [
                                _formatButton(Text("选择图片"), () {
                                  () async {
                                    await Routes.navigateTo(context, "/uploader", params: {"hash": attachHash, "uid": Application.user.uid.toString(), "fid": widget.fid.toString()});
                                    _loadAttaches();
                                    setState(() {});
                                  }();
                                }),
                              ]))
                        ]))
                  ])
                ]))
              ]))),
      new Visibility(visible: isLoading, child: new FadeTransition(opacity: _fadeAnimation["loading"], child: Center(child: CircularProgressIndicator()))),
      new Visibility(visible: isMessageShowing && !isLoading, child: new FadeTransition(opacity: _fadeAnimation["messaging"], child: Center(child: IconMessage(icon: icon, color: color, message: message))))
    ]);
    if (isLoading) {
      _fadeController["main"].reverse();
      _fadeController["messaging"].reverse();
      _fadeController["loading"].forward();
    } else if (isMessageShowing) {
      _fadeController["main"].reverse();
      _fadeController["messaging"].forward();
      _fadeController["loading"].reverse();
    } else {
      _fadeController["main"].forward();
      _fadeController["messaging"].reverse();
      _fadeController["loading"].reverse();
    }

    return Scaffold(body: SafeArea(bottom: true, child: el));
  }

  _setText(before, value, after) {
    var text = controller.text;
    var tStart = controller.selection.start == -1 ? 0 : controller.selection.start;
    var tEnd = controller.selection.end == -1 ? 0 : controller.selection.end;
    if (tStart == tEnd) {
      controller.text = text.substring(0, tStart) + before + value + after + text.substring(tStart, text.length);
    }
    var a = text.substring(0, tStart) + before;
    var b = value != "" ? value : text.substring(tStart, tEnd);
    var c = after + text.substring(tEnd, text.length);
    controller.text = a + b + c;
    controller.selection = TextSelection(baseOffset: a.length, extentOffset: a.length + b.length);
  }

  _formatButton(Widget widget, Function action) {
    return GestureDetector(
        onTap: () {
          action();
          setState(() {});
        },
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: widget));
  }
}

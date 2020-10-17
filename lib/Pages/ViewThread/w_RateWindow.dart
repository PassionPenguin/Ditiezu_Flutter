import 'package:flutter/material.dart';
import 'package:span_builder/span_builder.dart';
import 'package:universal_html/parsing.dart';

import '../../Network/Network.dart';
import '../../Utils/Exts.dart';
import '../../Widgets/v_empty_view.dart';
import '../../Widgets/w_counter.dart';
import '../../Widgets/w_iconMessage.dart';

class RateWindow extends StatefulWidget {
  final Function onFinish;
  final int pid;
  final int tid;
  final String formhash;

  const RateWindow({Key key, this.onFinish, this.tid, this.pid, this.formhash}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RateWindowState();
}

class _RateWindowState extends State<RateWindow> with TickerProviderStateMixin {
  bool isLoading = true;
  bool isMessageShowing = false;
  String message = "";
  IconData icon = Icons.check;
  Color color = Colors.green;
  Map<String, Animation<double>> _fadeAnimation = {};
  Map<String, AnimationController> _fadeController = {};

  String credit;

  @override
  void initState() {
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

    () async {
      var doc = parseHtmlDocument(await NetWork().get("http://www.ditiezu.com/forum.php?mod=misc&action=rate&tid=${widget.tid}&pid=${widget.pid}&infloat=yes&handlekey=rate&t=&inajax=1&ajaxtarget=fwin_content_rate"));
      setState(() {
        isLoading = false;
      });
      if (doc.containsQuery(".alert_error")) {
        message = doc.querySelector(".alert_error p").text;
        icon = Icons.close;
        color = Colors.red;
        Future.delayed(Duration(seconds: 1), () {
          widget.onFinish();
        });
        return;
      }

      credit = doc
          .querySelectorAll("tr")
          .where((i) {
            return i.children[0].text.contains("人气");
          })
          .toList()[0]
          .children[3]
          .text;
    }();
    super.initState();
  }

  var counter = Counter(min: -1, max: 1);
  var _reasonController = TextEditingController(text: "感谢分享！");

  @override
  Widget build(BuildContext context) {
    var el = Stack(children: [
      new Visibility(
          visible: !isMessageShowing && !isLoading,
          child: new FadeTransition(
              opacity: _fadeAnimation["main"],
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("评分", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                VEmptyView(6),
                Text("确认后您将会给ta上分～", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey)),
                VEmptyView(24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [Text.rich(TextSpan(children: SpanBuilder('𝑓人气').apply(TextSpan(text: "人气", style: TextStyle(fontSize: 10))).build())), counter, Text("x∈[-1, 1]∩𝑁"), Text("剩余额度: $credit")]),
                VEmptyView(12),
                TextField(controller: _reasonController),
                VEmptyView(24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [MaterialButton(color: Colors.grey[100], child: Text("取消"), onPressed: () => widget.onFinish()), MaterialButton(color: Colors.blue[100], child: Text("确认"), onPressed: () => _submit())])
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
    return Container(color: Colors.white, padding: EdgeInsets.only(top: 32, right: 32, bottom: 48, left: 32), child: el);
  }

  _submit() {
    int count = counter.state.count;
    if (_reasonController.text.isEmpty) {
      message = "请写上原因嗷";
      color = Colors.red;
      icon = Icons.close;
      isMessageShowing = true;
      setState(() {});
      Future.delayed(Duration(seconds: 2), () {
        isMessageShowing = false;
        setState(() {});
      });
      return;
    }
    if (count == 0) {
      message = "请选好加分呀";
      color = Colors.red;
      icon = Icons.close;
      isMessageShowing = true;
      setState(() {});
      Future.delayed(Duration(seconds: 2), () {
        isMessageShowing = false;
        setState(() {});
      });
      return;
    }
    () async {
      setState(() {
        isLoading = true;
      });
      var response = await NetWork().post("http://www.ditiezu.com/forum.php?mod=misc&action=rate&ratesubmit=yes&infloat=yes&inajax=1",
          "formhash=${widget.formhash}&tid=${widget.tid}&pid=${widget.pid}&handlekey=rate" + "&reason=${UrlEncode().encode(_reasonController.text)}" + "&score4=$count");
      setState(() {
        isLoading = false;
      });
      try {
        message = RegExp(",\ '(.*)\'").firstMatch(response).group(1);
        setState(() {
          if (response.contains("succeedhandle_rate=='function'")) {
            color = Colors.green;
            icon = Icons.check;
          } else {
            color = Colors.red;
            icon = Icons.close;
          }
        });
      } catch (e) {
        color = Colors.red;
        icon = Icons.close;
        message = "发生错误";
      }
      isMessageShowing = true;
      setState(() {});
      Future.delayed(Duration(seconds: 2), () {
        isMessageShowing = false;
        setState(() {});
      });
      Future.delayed(Duration(seconds: 3), () {
        widget.onFinish();
      });
    }();
  }
}

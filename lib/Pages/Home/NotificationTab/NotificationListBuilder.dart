import 'package:flutter/material.dart';

import '../../../Models/NotificationItem.dart';
import '../../../Route/Routes.dart';
import '../../../Widgets/v_empty_view.dart';

class NotificationList extends StatefulWidget {
  final List<NotificationItem> notificationList;

  const NotificationList({Key key, this.notificationList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  @override
  Widget build(BuildContext context) {
    var notificationList = widget.notificationList;
    return ListView.builder(
        itemBuilder: (BuildContext buildContext, int index) {
          var data = notificationList[index];
          return SafeArea(
              top: false,
              bottom: false,
              child: InkWell(
                  onTap: () {
                    Routes.navigateTo(context, Routes.thread, params: {'tid': data.tid.toString(), "page": data.page.toString()});
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, right: 24.0, left: 24.0),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Container(
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/images/noavatar_middle.png',
                                  imageErrorBuilder: (BuildContext context, Object error, StackTrace stackTrace) {
                                    return Image.asset("assets/images/noavatar_middle.png");
                                  },
                                  image: data.imageUrl,
                                ))),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.only(left: 8), child: Text(data.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                            data.description != null ? Padding(padding: EdgeInsets.only(top: 4, left: 8), child: Text(data.description)) : VEmptyView(0),
                            Padding(padding: EdgeInsets.only(top: 4, left: 8), child: Text(data.time, style: TextStyle(fontSize: 12))),
                          ],
                        )),
                      ]))));
        },
        itemCount: notificationList.length);
  }
}

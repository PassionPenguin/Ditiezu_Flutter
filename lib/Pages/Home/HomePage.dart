import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Utils/ScreenSize.dart';
import '../../app.dart';
import 'AccountTab/AccountTab.dart';
import 'CategoryTab.dart';
import 'DiscoveryTab.dart';
import 'NotificationTab/NotificationTab.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;

  int _selectIndex = 1;
  bool _isOnTab = false;

  TextStyle _defaultStyle = TextStyle(fontSize: 16);
  TextStyle _selectStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController(initialPage: 1);
  }

  _onTabPageChange(index, {bool isOnTab = false}) {
    if (_selectIndex == index) {
      return;
    }
    setState(() {
      _selectIndex = index;
    });

    if (!isOnTab) {
      _tabController.animateTo(_selectIndex);
    } else {
      _pageController.animateToPage(_selectIndex, duration: Duration(milliseconds: 200), curve: Curves.linear);
      //等待滑动解锁
      Future.delayed(Duration(milliseconds: 200), () {
        _isOnTab = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = Application.screenWidth;
    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
        preferredSize: Size.zero,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth >= 768 ? (screenWidth - 768) / 2 : 0),
              child: TabBar(
                  onTap: (index) {
                    _isOnTab = true;
                    _onTabPageChange(index, isOnTab: true);
                  },
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicator: UnderlineTabIndicator(),
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: FadeInImage.assetNetwork(width: 24, height: 24, placeholder: "assets/images/noavatar_middle.png", image: "http://ditiezu.com/uc_server/avatar.php?mod=avatar&uid=${Application.user.uid}")),
                    ),
                    Tab(
                      child: Text("发现", style: _selectIndex == 1 ? _selectStyle : _defaultStyle),
                    ),
                    Tab(
                      child: Text("分区", style: _selectIndex == 2 ? _selectStyle : _defaultStyle),
                    ),
                    Tab(
                      child: Text("通知", style: _selectIndex == 3 ? _selectStyle : _defaultStyle),
                    ),
                  ]),
            ),
            Expanded(
              child: PageView(
                onPageChanged: (index) {
                  if (!_isOnTab) {
                    _onTabPageChange(index, isOnTab: false);
                  }
                },
                controller: _pageController,
                children: <Widget>[
                  Center(
                      child: Container(
                    height: height(context),
                    width: width(context),
                    child: AccountTab(),
                  )),
                  Center(
                      child: Container(
                    height: height(context),
                    width: width(context),
                    child: DiscoveryTab(context),
                  )),
                  Center(
                      child: Container(
                    height: height(context),
                    width: width(context),
                    child: CategoryTab(context),
                  )),
                  Center(
                      child: Container(
                    height: height(context),
                    width: width(context),
                    child: NotificationTab(context),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

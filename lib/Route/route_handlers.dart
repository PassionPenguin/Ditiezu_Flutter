// splash 页面
import 'package:ditiezu_app/pages/Home/account_tab.dart';
import 'package:ditiezu_app/pages/Home/home_page.dart';
import 'package:ditiezu_app/pages/LoginPage.dart';
import 'package:ditiezu_app/pages/ViewForum.dart';
import 'package:ditiezu_app/pages/ViewThread.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';

// 登录页
var loginHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return LoginPage();
});

// 跳转到主页
var homeHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return HomePage();
});

var forumHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return ViewForum(int.parse(params["fid"]?.first));
});

var threadHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return ViewThread(int.parse(params["tid"]?.first), int.parse(params["page"]?.first));
});


var accountHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return AccountTab();
});

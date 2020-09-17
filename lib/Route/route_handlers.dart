// splash 页面
import 'package:ditiezu_app/pages/home_page.dart';
import 'package:ditiezu_app/pages/login_page.dart';
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

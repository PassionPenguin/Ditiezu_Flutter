import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:ditiezu_app/Route/route_handlers.dart';

class Routes {
  static Router router;
  static String root = "/";
  static String home = "/home";
  static String login = "/login";
  // 配置route
  static void configureRoutes(Router router) {
    // 未发现对应route
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      print('route not found!');
      return;
    });

    router.define(home, handler: homeHandler); // 设置
    router.define(login, handler: loginHandler); // 网页加载
  }

  // 对参数进行encode，解决参数中有特殊字符，影响fluro路由匹配
  static Future navigateTo(BuildContext context, String path, {Map<String, dynamic> params, TransitionType transition = TransitionType.native}) {
    String query =  "";
    if (params != null) {
      int index = 0;
      for (var key in params.keys) {
        var value = Uri.encodeComponent(params[key]);
        if (index == 0) {
          query = "?";
        } else {
          query = query + "\&";
        }
        query += "$key=$value";
        index++;
      }
    }
    print('我是navigateTo传递的参数：$query');

    path = path + query;
    return router.navigateTo(context, path, transition:transition);
  }
}

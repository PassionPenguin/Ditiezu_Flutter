import 'package:ditiezu_app/Route/route_handlers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart' hide Router;

class Routes {
  static Router router;
  static String root = "/";
  static String home = "/home";
  static String login = "/login";
  static String forum = "/forum";
  static String thread = "/thread";

  // 配置route
  static void configureRoutes(Router router) {
    // 未发现对应route
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      print('route not found!');
      return;
    });

    router.define(home, handler: homeHandler);
    router.define(login, handler: loginHandler);
    router.define(forum, handler: forumHandler);
    router.define(thread, handler: threadHandler);
  }

  // 对参数进行encode，解决参数中有特殊字符，影响fluro路由匹配
  static Future navigateTo(BuildContext context, String path, {Map<String, dynamic> params, TransitionType transition = TransitionType.native}) {
    String query = "";
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

    path = path + query;
    return router.navigateTo(context, path, transition: transition);
  }
}

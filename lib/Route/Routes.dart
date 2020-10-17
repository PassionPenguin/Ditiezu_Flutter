import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart' hide Router;

import 'RouteHandlers.dart';

class Routes {
  static Router router;
  static String root = "/";
  static String home = "/home";
  static String login = "/login";
  static String forum = "/forum";
  static String thread = "/thread";
  static String post = "/post";
  static String uploader = "/uploader";
  static String license = "/license";
  static String openSourceLicense = "/openSourceLicense";
  static String privacy = "/privacy";

  // 配置route
  static void configureRoutes(Router router) {
    // 未发现对应route
    router.notFoundHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      print('Route not found!');
      throw NullThrownError();
    });

    router.define(home, handler: homeHandler);
    router.define(login, handler: loginHandler);
    router.define(forum, handler: forumHandler);
    router.define(thread, handler: threadHandler);
    router.define(post, handler: postHandler);
    router.define(uploader, handler: uploaderHandler);
    router.define(license, handler: licenseHandler);
    router.define(openSourceLicense, handler: openSourceLicenseHandler);
    router.define(privacy, handler: privacyHandler);
  }

  static Future navigateTo(BuildContext context, String path, {Map<String, dynamic> params, TransitionType transition = TransitionType.native, clearStack = false}) {
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
    return router.navigateTo(context, path, transition: transition, clearStack: clearStack);
  }

  static void pop(BuildContext context) {
    return router.pop(context);
  }
}

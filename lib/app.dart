import 'package:ditiezu_app/provider/user_model.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/user.dart';

class Application {
  static Router router;
  static GlobalKey<NavigatorState> key = GlobalKey();
  static SharedPreferences sp;
  static double screenWidth;
  static double screenHeight;
  static double statusBarHeight;
  static double bottomBarHeight;
  static User user;

  static init(context) async {
    sp = await SharedPreferences.getInstance();
    user = UserModel.init(sp).user;
    ScreenUtil.init(context, width: 750, height: 1334);
  }
}

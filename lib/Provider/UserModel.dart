import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/User.dart';
import '../app.dart';

class UserModel with ChangeNotifier {
  UserModel();

  UserModel.init(SharedPreferences sp) {
    if (sp.containsKey('user')) {
      String s = sp.getString('user');
      _user = User.fromJson(json.decode(s));
    } else
      _user = null;
  }

  User _user;

  User get user => _user;

  /// 保存用户信息到 sp
  static saveUserInfo(User user) {
    Application.sp.setString('user', json.encode(user.toJson()));
  }
}

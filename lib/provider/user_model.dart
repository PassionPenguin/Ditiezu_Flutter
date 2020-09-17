import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ditiezu_app/app.dart';
import 'package:ditiezu_app/model/user.dart';

class UserModel with ChangeNotifier {
  User _user;
  User get user => _user;

  /// 初始化 User
  void initUser() {
    if (Application.sp.containsKey('user')) {
      String s = Application.sp.getString('user');
      _user = User.fromJson(json.decode(s));
    }
  }

  /// 保存用户信息到 sp
  _saveUserInfo(User user) {
    _user = user;
    Application.sp.setString('user', json.encode(user.toJson()));
  }
}

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import '../Pages/Editor/ImageUploader.dart';
import '../Pages/Editor/Post.dart';
import '../Pages/Home/AccountTab/License.dart';
import '../Pages/Home/AccountTab/OpenSource.dart';
import '../Pages/Home/AccountTab/Privacy.dart';
import '../Pages/Home/HomePage.dart';
import '../Pages/LoginPage.dart';
import '../Pages/ViewForum.dart';
import '../Pages/ViewThread/ViewThread.dart';
import '../Utils/Exts.dart';

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

var postHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  switch (params["mode"]?.first.toString()) {
    case "REPLY":
      return Post.reply(tid: params["tid"].first.toString().toInt(), fid: params["fid"].first.toString().toInt(), pid: params["pid"].first.toString().toInt());
      break;
    case "EDIT":
      return Post.edit(pid: params["pid"].first.toString().toInt(), tid: params["tid"].first.toString().toInt(), fid: params["fid"].first.toString().toInt());
      break;
    case "SIGHTML":
      return Post.signature();
      break;
    default:
      return Post.post(fid: params["fid"].first.toString().toInt());
  }
});

var uploaderHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return ImageUploader(params["hash"].first.toString(), params["uid"].first.toString().toInt(), params["fid"].first.toString().toInt());
});

var licenseHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return License();
});

var openSourceLicenseHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return OpenSourceLicense();
});

var privacyHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return Privacy();
});

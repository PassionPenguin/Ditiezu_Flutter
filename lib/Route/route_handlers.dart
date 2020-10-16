// splash 页面
import 'package:Ditiezu/pages/Editor/Post.dart';
import 'package:Ditiezu/pages/Editor/UploadImages.dart';
import 'package:Ditiezu/pages/Home/home_page.dart';
import 'package:Ditiezu/pages/License.dart';
import 'package:Ditiezu/pages/LoginPage.dart';
import 'package:Ditiezu/pages/OpenSource.dart';
import 'package:Ditiezu/pages/ViewForum.dart';
import 'package:Ditiezu/pages/ViewThread/ViewThread.dart';
import 'package:Ditiezu/utils/exts.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';

// 登录页
var loginHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return LoginPage();
});

// 跳转到主页
var homeHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return HomePage();
});

var forumHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return ViewForum(int.parse(params["fid"]?.first));
});

var threadHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return ViewThread(
      int.parse(params["tid"]?.first), int.parse(params["page"]?.first));
});

var postHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  switch (params["mode"]?.first.toString()) {
    case "REPLY":
      return Post.reply(
          tid: params["tid"].first.toString().toInt(),
          fid: params["fid"].first.toString().toInt(),
          pid: params["pid"].first.toString().toInt());
      break;
    case "EDIT":
      return Post.edit(
          pid: params["pid"].first.toString().toInt(),
          tid: params["tid"].first.toString().toInt(),
          fid: params["fid"].first.toString().toInt());
      break;
    default:
      return Post.post(fid: params["fid"].first.toString().toInt());
  }
});

var uploaderHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
  return UploadImages(
      params["hash"].first.toString(),
      params["uid"].first.toString().toInt(),
      params["fid"].first.toString().toInt());
});

var licenseHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
      return License();
});


var openSourceLicenseHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<Object>> params) {
      return OpenSourceLicense();
});

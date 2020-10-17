import 'package:flutter/material.dart';

import '../../../Route/Routes.dart';

class Privacy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
                child: Icon(Icons.arrow_back_ios, color: Colors.black),
                onTap: () {
                  Routes.pop(context);
                }),
            title: Text("隐私政策", style: TextStyle(color: Colors.black))),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('''本应用仅使用您的账户密码等信息获取COOKIE，记录内容仅包括用户名、UID、登录状况以实时渲染UI。由于图片选择功能，您需要提供图片权限。由于HTTP明文传输，您的数据不受到任何保障。''', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
        ));
  }
}

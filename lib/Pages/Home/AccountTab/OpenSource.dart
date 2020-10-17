import 'package:flutter/material.dart';

import '../../../Data/OpenSourceData.dart';
import '../../../Route/Routes.dart';

class OpenSourceLicense extends StatelessWidget {
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
            title: Text("开源许可", style: TextStyle(color: Colors.black))),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Column(children: [
                  Text(openSourceList[index].softwareName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(openSourceList[index].softwareLicense, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)))
                ]);
              },
              itemCount: openSourceList.length,
            )));
  }
}

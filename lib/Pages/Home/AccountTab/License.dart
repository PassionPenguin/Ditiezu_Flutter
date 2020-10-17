import 'package:flutter/material.dart';

import '../../../Route/Routes.dart';

class License extends StatelessWidget {
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
            title: Text("用户协议", style: TextStyle(color: Colors.black))),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('''Copyright 2020 PassionPenguin

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

This software was compiled from PassionPenguin/Ditiezu, and this software is only for studying.''',
                style: TextStyle(fontSize: 14, color: Colors.black, decoration: null))));
  }
}

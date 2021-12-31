import 'dart:io';

import 'package:ditiezu/data/theme.dart';
import 'package:ditiezu/widget/extended_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/home/home_page.dart';

void main() {
  runApp(const Application());
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);
  static late BuildContext context;

  @override
  Widget build(BuildContext context) {
    Application.context = context;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light));

    return MaterialApp(
      title: 'Ditiezu',
      theme: baseThemeData,
      debugShowCheckedModeBanner: false,
      home:  const ExtendedPage(child: HomePage()),
    );
  }
}

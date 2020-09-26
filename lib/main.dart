import 'package:ditiezu_app/Route/routes.dart';
import 'package:ditiezu_app/pages/init_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';

void main() {
  final router = Router();
  Routes.configureRoutes(router);
  Routes.router = router;
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ditiezu',
        onGenerateRoute: Routes.router.generator, // 配置route generate
        home: SplashPage());
  }
}

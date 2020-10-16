import 'package:Ditiezu/Route/routes.dart';
import 'package:Ditiezu/pages/InitPage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart' hide Router;

void main() {
  final router = Router();
  Routes.configureRoutes(router);
  Routes.router = router;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.light(),
        debugShowCheckedModeBanner: false,
        title: 'Ditiezu',
        onGenerateRoute: Routes.router.generator,
        // 配置route generate
        home: SplashPage());
  }
}

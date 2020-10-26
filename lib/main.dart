import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart' hide Router;

import 'Pages/StartupPage.dart';
import 'Route/Routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final router = Router();
  Routes.configureRoutes(router);
  Routes.router = router;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done || snapshot.hasError) {
            return MaterialApp(
                theme: ThemeData.light(),
                debugShowCheckedModeBanner: false,
                title: 'Ditiezu',
                onGenerateRoute: Routes.router.generator,
                // 配置route generate
                home: SplashPage());
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return MaterialApp(
              theme: ThemeData.light(),
              debugShowCheckedModeBanner: false,
              title: 'Ditiezu',
              onGenerateRoute: Routes.router.generator,
              // 配置route generate
              home: Scaffold(body: Center(child: CircularProgressIndicator())));
        });
  }
}

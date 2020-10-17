import 'package:flutter/material.dart';

import '../Route/Routes.dart';
import '../app.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController _logoController;
  Tween _scaleTween;
  CurvedAnimation _logoAnimation;

  @override
  void initState() {
    super.initState();
    _scaleTween = Tween(begin: 0, end: 1);
    _logoController = AnimationController(duration: Duration(milliseconds: 500), vsync: this)..drive(_scaleTween);
    Future.delayed(Duration(milliseconds: 500), () {
      _logoController.forward();
    });
    _logoAnimation = CurvedAnimation(parent: _logoController, curve: Curves.easeOutQuart);

    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 500), () {
          goPage();
        });
      }
    });
  }

  void goPage() async {
    await Application.init(context);
    if (Application.user != null)
      Future.delayed(Duration(seconds: 2), () {
        Routes.navigateTo(context, "/home", clearStack: true);
      });
    else
      Future.delayed(Duration(seconds: 2), () {
        Routes.navigateTo(context, "/login", clearStack: true);
      });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Application.screenWidth = size.width;
    Application.screenHeight = size.height;
    Application.statusBarHeight = MediaQuery.of(context).padding.top;
    Application.bottomBarHeight = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: ScaleTransition(
          scale: _logoAnimation,
          child: Hero(
            tag: 'logo',
            child: Stack(children: [Positioned(bottom: 24, child: CircularProgressIndicator())], alignment: Alignment.center),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _logoController.dispose();
  }
}

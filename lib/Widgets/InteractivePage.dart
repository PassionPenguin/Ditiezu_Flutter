import 'package:Ditiezu/Widgets/w_iconMessage.dart';
import 'package:flutter/material.dart';

abstract class InteractivePage {
  // Interactive Indicators
  bool _isLoading = false;
  bool _isMessageShowing = false;
  String _message = "";
  IconData _icon = Icons.check;
  Color _color = Colors.green;
  Map<String, Animation<double>> __fadeAnimation = {};
  Map<String, AnimationController> __fadeController = {};

  bool get isLoading {
    return _isLoading;
  }

  set isLoading(loadingState) {
    _isLoading = loadingState;
  }

  bool get isMessageShowing {
    return _isMessageShowing;
  }

  set isMessageShowing(messageState) {
    _isMessageShowing = messageState;
  }

  get fadeController {
    return __fadeController;
  }

  set fadeController(ctrl) {
    __fadeController = ctrl;
  }

  get fadeAnimation {
    return __fadeAnimation;
  }

  set fadeAnimation(anim) {
    __fadeAnimation = anim;
  }

  IconMessage icnMessage() {
    return IconMessage(icon: _icon, color: _color, message: _message);
  }

  void showLoading() {
    fadeController["loading"].forward();
    fadeController["main"].reverse();
    fadeController["messaging"].reverse();
    if (_parentState.mounted)
      // ignore: invalid_use_of_protected_member
      _parentState.setState(() {
        _isLoading = true;
        _isMessageShowing = false;
      });
  }

  void showMessage(String message, Color color, IconData icon) {
    fadeController["main"].reverse();
    fadeController["messaging"].forward();
    if (_loadingEnabled) fadeController["loading"].reverse();
    if (_parentState.mounted) {
      // ignore: invalid_use_of_protected_member
      _parentState.setState(() {
        _isMessageShowing = isMessageShowing;
        _message = message;
        _color = color;
        _icon = _icon;
      });
      Future.delayed(Duration(seconds: 2), () {
        // ignore: invalid_use_of_protected_member
        _parentState.setState(() {
          _isMessageShowing = false;
          fadeController["main"].forward();
          fadeController["messaging"].reverse();
          if (_loadingEnabled) fadeController["loading"].reverse();
        });
      });
    }
  }

  void clearAnim() {
    fadeController["loading"].reverse();
    fadeController["messaging"].reverse();
    fadeController["main"].forward();

    if (_parentState.mounted)
      // ignore: invalid_use_of_protected_member
      _parentState.setState(() {
        _isLoading = false;
        _isMessageShowing = false;
      });
  }

  // Preferences
  bool _loadingEnabled;

  // State
  State _parentState;
  TickerProvider _tickerProvider;

  @mustCallSuper
  @protected
  void bindIntractableWidgets(bool loadingEnabled, parentState) {
    _loadingEnabled = loadingEnabled;
    _parentState = parentState;
    _tickerProvider = parentState;

    fadeController["main"] = new AnimationController(vsync: _tickerProvider, duration: Duration(seconds: 1));
    fadeController["messaging"] = new AnimationController(vsync: _tickerProvider, duration: Duration(seconds: 1));
    fadeController["loading"] = new AnimationController(vsync: _tickerProvider, duration: Duration(seconds: 1));
    fadeAnimation["main"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(fadeController["main"]);
    fadeAnimation["messaging"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(fadeController["messaging"]);
    fadeAnimation["loading"] = new Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(fadeController["loading"]);
    fadeController["main"].forward();
  }
}

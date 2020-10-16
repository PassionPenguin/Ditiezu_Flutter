import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum Toast { LENGTH_SHORT, LENGTH_LONG }

enum ToastGravity { TOP, BOTTOM, CENTER, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, CENTER_LEFT, CENTER_RIGHT, SNACKBAR }

typedef PositionedToastBuilder = Widget Function(BuildContext context, Widget child);

class FToast {
  BuildContext context;

  static final FToast _instance = FToast._internal();

  factory FToast() {
    return _instance;
  }

  init(BuildContext context) {
    _instance.context = context;
  }

  FToast._internal();

  OverlayEntry _entry;
  Timer _timer;
  ToastStateFul child;
  Duration toastDuration;

  _showOverlay() {
    if (context == null) throw ("Error: Context is null, Please call init(context) before showing toast.");
    Overlay.of(context).insert(_entry);

    // if (toastDuration != null)
    //   Future.delayed(toastDuration, () {
    //     remove();
    //   });
  }

  remove() {
    _timer?.cancel();
    _timer = null;
    _entry.remove();
    // if (_entry != null) _entry.remove();
    // _showOverlay();
  }

  // removeQueuedCustomToasts() {
  //   _timer?.cancel();
  //   _timer = null;
  //   _overlayQueue.forEach((e){
  //     e.entry.remove();
  //   });
  //   _overlayQueue.clear();
  //   if (_entry != null) _entry.remove();
  //   _entry = null;
  // }

  void showToast({
    @required Widget child,
    PositionedToastBuilder positionedToastBuilder,
    Duration toastDuration,
    ToastGravity gravity,
  }) {
    child = ToastStateFul(child, toastDuration);
    _entry = OverlayEntry(builder: (context) {
      if (positionedToastBuilder != null) return positionedToastBuilder(context, child);
      return _getPostionWidgetBasedOnGravity(child, gravity);
    });
    _showOverlay();
  }

  _getPostionWidgetBasedOnGravity(Widget child, ToastGravity gravity) {
    switch (gravity) {
      case ToastGravity.TOP:
        return Positioned(top: 100.0, left: 24.0, right: 24.0, child: child);
        break;
      case ToastGravity.TOP_LEFT:
        return Positioned(top: 100.0, left: 24.0, child: child);
        break;
      case ToastGravity.TOP_RIGHT:
        return Positioned(top: 100.0, right: 24.0, child: child);
        break;
      case ToastGravity.CENTER:
        return Positioned(top: 50.0, bottom: 50.0, left: 24.0, right: 24.0, child: child);
        break;
      case ToastGravity.CENTER_LEFT:
        return Positioned(top: 50.0, bottom: 50.0, left: 24.0, child: child);
        break;
      case ToastGravity.CENTER_RIGHT:
        return Positioned(top: 50.0, bottom: 50.0, right: 24.0, child: child);
        break;
      case ToastGravity.BOTTOM_LEFT:
        return Positioned(bottom: 50.0, left: 24.0, child: child);
        break;
      case ToastGravity.BOTTOM_RIGHT:
        return Positioned(bottom: 50.0, right: 24.0, child: child);
        break;
      case ToastGravity.SNACKBAR:
        return Positioned(bottom: MediaQuery.of(context).viewInsets.bottom, left: 0, right: 0, child: child);
        break;
      case ToastGravity.BOTTOM:
      default:
        return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
    }
  }
}

class ToastStateFul extends StatefulWidget {
  ToastStateFul(this.child, this.duration, {Key key}) : super(key: key);

  final Widget child;
  final Duration duration;

  @override
  ToastStateFulState createState() => ToastStateFulState();
}

class ToastStateFulState extends State<ToastStateFul> with SingleTickerProviderStateMixin {
  showIt() {
    _animationController.forward();
  }

  hideIt() {
    _animationController.reverse();
  }

  AnimationController _animationController;
  Animation _fadeAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    super.initState();

    showIt();
    if (widget.duration != null)
      Future.delayed(widget.duration, () {
        hideIt();
      });
  }

  @override
  void deactivate() {
    _animationController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}

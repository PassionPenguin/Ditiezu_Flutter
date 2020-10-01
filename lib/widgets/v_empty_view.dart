import 'package:flutter/material.dart';

class VEmptyView extends StatelessWidget {
  final double height;

  VEmptyView(this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}

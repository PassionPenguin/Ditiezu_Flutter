import 'package:flutter/material.dart';

class RoundImgWidget extends StatelessWidget {
  final String img;
  final double width;
  final BoxFit fit;

  RoundImgWidget(this.img, this.width, {this.fit});

  @override
  Widget build(BuildContext context) {
    Image e;
    try {
      e = Image(image: NetworkImage(img), width: width, height: width, fit: fit);
    } catch (err) {
      e = Image.asset("assets/image/noavatar_middle.png", width: width, height: width, fit: fit);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(width / 2),
      child: e,
    );
  }
}

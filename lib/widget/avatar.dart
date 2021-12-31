import 'package:ditiezu/io/network.dart';
import 'package:ditiezu/io/network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({Key? key, required this.uid, this.width = 24}) : super(key: key);
  final int uid;
  final double width;

  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(width),
      child: Image(
        fit: BoxFit.cover,
        image: ExtendedNetworkImage(
            hostIP + "uc_server/avatar.php?mod=avatar&uid=$uid",
            headers: queryHeaders),
        width: width,
        height: width
      ));
}

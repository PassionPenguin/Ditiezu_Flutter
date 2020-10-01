import 'package:flutter/cupertino.dart';

double width(BuildContext ctx){
  return MediaQuery.of(ctx).size.width;
}
double height(BuildContext ctx){
  return MediaQuery.of(ctx).size.height;
}
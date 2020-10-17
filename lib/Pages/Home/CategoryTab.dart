import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Data/CategoryData.dart';
import '../../Route/Routes.dart';

class CategoryTab extends StatefulWidget {
  CategoryTab(this.ctx);

  final BuildContext ctx;

  @override
  State<StatefulWidget> createState() => _CategoryTabState(ctx);
}

class _CategoryTabState extends State<CategoryTab> {
  _CategoryTabState(this.ctx);

  BuildContext ctx;
  List<Widget> categoryItems = [SizedBox()];

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 0), () {
      () async {
        try {
          categoryItems = categoryList.map((e) {
            return FlatButton(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                height: 48,
                child: Row(children: [
                  Padding(padding: EdgeInsets.all(16)),
                  SvgPicture.asset(e.categoryIcon, width: 28, height: 28),
                  Padding(padding: EdgeInsets.only(left: 8)),
                  Text(e.categoryName, style: TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500))
                ]),
                onPressed: () {
                  Routes.navigateTo(context, Routes.forum, params: {'fid': e.categoryID.toString()});
                });
          }).toList();
          setState(() {});
        } catch (e) {}
      }();
    });
    return GridView.count(crossAxisCount: 2, childAspectRatio: MediaQuery.of(context).size.width / 96, children: categoryItems);
  }
}

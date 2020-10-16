import 'package:Ditiezu/model/SelectItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildCheckItem(BuildContext context, SelectItem data, bool selected) {
  return new Padding(
      padding: new EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          new Text(
            data.name,
            style: selected
                ? new TextStyle(
                fontSize: 14.0,
                color: Theme
                    .of(context)
                    .primaryColor,
                fontWeight: FontWeight.w400)
                : new TextStyle(fontSize: 14.0),
          ),
          new Expanded(
              child: new Align(
                alignment: Alignment.centerRight,
                child: selected
                    ? new Icon(
                  Icons.check,
                  color: Theme
                      .of(context)
                      .primaryColor,
                  size: 18,
                )
                    : null,
              )),
        ],
      ));
}

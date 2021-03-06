import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
// ignore: implementation_imports
import 'package:html/src/query_selector.dart';

import '../../Exts.dart';
import '../style.dart';

/// A [StyledElement] applies a style to all of its children.
class StyledElement {
  final String name;
  final String elementId;
  final List<String> elementClasses;
  List<StyledElement> children;
  Style style;
  final dom.Node _node;

  StyledElement({
    this.name = "[[No name]]",
    this.elementId,
    this.elementClasses,
    this.children,
    this.style,
    dom.Element node,
  }) : this._node = node;

  bool matchesSelector(String selector) => _node != null && matches(_node, selector);

  Map<String, String> get attributes => _node.attributes.map((key, value) {
        return MapEntry(key, value);
      });

  dom.Element get element => _node;

  @override
  String toString() {
    String selfData =
        "[$name] ${children?.length ?? 0} ${elementClasses?.isNotEmpty == true ? 'C:${elementClasses.toString()}' : ''}${elementId?.isNotEmpty == true ? 'ID: $elementId' : ''}";
    children?.forEach((child) {
      selfData += ("\n${child.toString()}").replaceAll(RegExp("^", multiLine: true), "-");
    });
    return selfData;
  }
}

StyledElement parseStyledElement(dom.Element element, List<StyledElement> children) {
  StyledElement styledElement = StyledElement(
    name: element.localName,
    elementId: element.id,
    elementClasses: element.classes.toList(),
    children: children,
    node: element,
  );

  if (element.classes.contains("noStyle")) return styledElement;
  if (element.classes.contains("xi1")) styledElement.style = Style(color: Colors.orange[600]);

  switch (element.localName) {
    case "abbr":
    case "acronym":
      styledElement.style = Style(
        textDecoration: TextDecoration.underline,
        textDecorationStyle: TextDecorationStyle.dotted,
      );
      break;
    case "address":
      continue italics;
    case "article":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "aside":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    bold:
    case "b":
      styledElement.style = Style(
        fontWeight: FontWeight.bold,
      );
      break;
    case "bdo":
      TextDirection textDirection = ((element.attributes["dir"] ?? "ltr") == "rtl") ? TextDirection.rtl : TextDirection.ltr;
      styledElement.style = Style(
        direction: textDirection,
      );
      break;
    case "big":
      styledElement.style = Style(
        fontSize: FontSize.larger,
      );
      break;
    case "blockquote":
      if (element.parent.localName == "blockquote") {
        styledElement.style = Style(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            margin: const EdgeInsets.symmetric(vertical: 12.0),
            border: Border(left: BorderSide(color: Colors.lightBlue[100], width: 6, style: BorderStyle.solid)),
            display: Display.BLOCK,
            color: Colors.grey,
            fontSize: FontSize.small);
      } else {
        styledElement.style = Style(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            margin: const EdgeInsets.symmetric(vertical: 12.0),
            border: Border(left: BorderSide(color: Colors.lightBlue[100], width: 6, style: BorderStyle.solid)),
            display: Display.BLOCK,
            color: Colors.grey,
            fontSize: FontSize.small);
      }
      break;
    case "body":
      styledElement.style = Style(
        margin: EdgeInsets.all(8.0),
        display: Display.BLOCK,
      );
      break;
    case "center":
      styledElement.style = Style(
        alignment: Alignment.center,
        display: Display.BLOCK,
      );
      break;
    case "cite":
      continue italics;
    monospace:
    case "code":
      styledElement.style = Style(
        fontFamily: 'Monospace',
      );
      break;
    case "dd":
      styledElement.style = Style(
        margin: EdgeInsets.only(left: 40.0),
        display: Display.BLOCK,
      );
      break;
    strikeThrough:
    case "del":
      styledElement.style = Style(
        textDecoration: TextDecoration.lineThrough,
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(vertical: 6),
      );
      break;
    case "dfn":
      continue italics;
    case "div":
      if (element.classes.contains("locked"))
        styledElement.style = Style(
            border: Border.all(color: Colors.red[200], width: 0.5),
            margin: EdgeInsets.only(top: 12, bottom: 3),
            padding: EdgeInsets.all(3),
            display: Display.BLOCK,
            fontSize: FontSize.small,
            color: Colors.grey); // Locked Element
      else
        styledElement.style = Style(
          margin: EdgeInsets.all(0),
          display: Display.BLOCK,
        );
      break;
    case "dl":
      styledElement.style = Style(
        margin: EdgeInsets.symmetric(vertical: 14.0),
        display: Display.BLOCK,
      );
      break;
    case "dt":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "em":
      continue italics;
    case "figcaption":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "figure":
      styledElement.style = Style(
        margin: EdgeInsets.symmetric(vertical: 14.0, horizontal: 40.0),
        display: Display.BLOCK,
      );
      break;
    case "footer":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "h1":
      styledElement.style = Style(
        fontSize: FontSize.xxLarge,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 18.67),
        display: Display.BLOCK,
      );
      break;
    case "h2":
      styledElement.style = Style(
        fontSize: FontSize.xLarge,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 17.5),
        display: Display.BLOCK,
      );
      break;
    case "h3":
      styledElement.style = Style(
        fontSize: FontSize(16.38),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 16.5),
        display: Display.BLOCK,
      );
      break;
    case "h4":
      styledElement.style = Style(
        fontSize: FontSize.medium,
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 18.5),
        display: Display.BLOCK,
      );
      break;
    case "h5":
      styledElement.style = Style(
        fontSize: FontSize(11.62),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 19.25),
        display: Display.BLOCK,
      );
      break;
    case "h6":
      styledElement.style = Style(
        fontSize: FontSize(9.38),
        fontWeight: FontWeight.bold,
        margin: EdgeInsets.symmetric(vertical: 22),
        display: Display.BLOCK,
      );
      break;
    case "header":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "hr":
      styledElement.style = Style(
        margin: EdgeInsets.only(top: 3.0, bottom: 6.0),
        width: double.infinity,
        height: 1,
        border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey[300])),
        display: Display.BLOCK,
      );
      break;
    case "html":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    italics:
    case "i":
      if (element.classes.contains("pstatus"))
        styledElement.style = Style(fontStyle: FontStyle.italic, fontSize: FontSize.small, color: Colors.grey);
      else
        styledElement.style = Style(
          fontStyle: FontStyle.italic,
        );
      break;
    case "ins":
      continue underline;
    case "kbd":
      continue monospace;
    case "li":
      styledElement.style = Style(
        display: Display.LIST_ITEM,
      );
      break;
    case "main":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "mark":
      styledElement.style = Style(
        color: Colors.black,
        backgroundColor: Colors.yellow,
      );
      break;
    case "nav":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "noscript":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "ol":
    case "ul":
      //TODO(Sub6Resources): This is a workaround for collapsed margins. Remove.
      if (element.parent.localName == "li") {
        styledElement.style = Style(
//          margin: EdgeInsets.only(left: 30.0),
          display: Display.BLOCK,
          listStyleType: element.localName == "ol" ? ListStyleType.DECIMAL : ListStyleType.DISC,
        );
      } else {
        styledElement.style = Style(
//          margin: EdgeInsets.only(left: 30.0, top: 14.0, bottom: 14.0),
          display: Display.BLOCK,
          listStyleType: element.localName == "ol" ? ListStyleType.DECIMAL : ListStyleType.DISC,
        );
      }
      break;
    case "p":
      styledElement.style = Style(
        margin: EdgeInsets.symmetric(vertical: 14.0),
        display: Display.BLOCK,
      );
      break;
    case "pre":
      styledElement.style = Style(
        fontFamily: 'monospace',
        margin: EdgeInsets.symmetric(vertical: 14.0),
        whiteSpace: WhiteSpace.PRE,
        display: Display.BLOCK,
      );
      break;
    case "q":
      styledElement.style = Style(
        before: "\"",
        after: "\"",
      );
      break;
    case "s":
      continue strikeThrough;
    case "samp":
      continue monospace;
    case "section":
      styledElement.style = Style(
        display: Display.BLOCK,
      );
      break;
    case "small":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
      );
      break;
    case "strike":
      continue strikeThrough;
    case "strong":
      continue bold;
    case "sub":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.SUB,
      );
      break;
    case "sup":
      styledElement.style = Style(
        fontSize: FontSize.smaller,
        verticalAlign: VerticalAlign.SUPER,
      );
      break;
    case "th":
      continue bold;
    case "tt":
      continue monospace;
    underline:
    case "u":
      styledElement.style = Style(
        textDecoration: TextDecoration.underline,
      );
      break;
    case "var":
      continue italics;
      break;
    case "font":
      var style = Style();
      if (element.attributes["size"] != null)
        switch (element.attributes["size"]) {
          case "0":
          case "1":
            style.fontSize = FontSize.xxSmall;
            break;
          case "2":
            style.fontSize = FontSize.xSmall;
            break;
          case "3":
            style.fontSize = FontSize.small;
            break;
          case "4":
            style.fontSize = FontSize.medium;
            break;
          case "5":
            style.fontSize = FontSize.large;
            break;
          case "6":
            style.fontSize = FontSize.xLarge;
            break;
          case "7":
            style.fontSize = FontSize.xxLarge;
            break;
        }
      if (element.attributes["color"] != null) {
        var color = element.attributes["color"];

        if (color.contains("#"))
          style.color = HexColor.fromHex(color);
        else if (color.contains("rgb")) style.color = RGBColor.fromRGB(color);
      }
      styledElement.style = style;
      break;
  }

  if(element.id^"rateContainer")styledElement.style.margin = EdgeInsets.only(top: 24);
  if (element.cssStyle.values["margin"] == "0") styledElement.style.margin = EdgeInsets.all(0);
  return styledElement;
}

typedef ListCharacter = String Function(int i);

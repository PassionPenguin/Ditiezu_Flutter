import 'dart:collection';
import 'dart:ui';

import 'package:html/dom.dart' as dom;
import 'package:universal_html/prefer_sdk/html.dart';

class CSSStyle {
  CSSStyle(this.el);

  dom.Element el;

  LinkedHashMap<String, String> get values {
    var map = <String, String>{};
    if (el.attributes["style"] == null) return map;
    el.attributes["style"].split(";").forEach((e) {
      var attr = e.split(":");
      if (attr.length > 2) map[attr[0]] = attr[1];
    });
    return map;
  }
}

extension domEl on dom.Element {
  bool containsQuery(query) {
    return this.querySelectorAll(query).isNotEmpty;
  }

  CSSStyle get cssStyle {
    return CSSStyle(this);
  }
}

extension El on Element {
  bool containsQuery(query) {
    return this.querySelectorAll(query).isNotEmpty;
  }
}

extension HDoc on HtmlDocument {
  bool containsQuery(query) {
    return this.querySelectorAll(query).isNotEmpty;
  }
}

extension Number on num {
  bool isIn(a, b) {
    return this <= b && this >= a;
  } // 区间判断
}

extension Str on String {
  bool operator ^(String another) {
    return this.startsWith(another);
  }

  int toInt() {
    return int.parse(this);
  }

  double toDouble() {
    return double.parse(this);
  }

  bool isNumeric() {
    if (this == null) {
      return false;
    }
    return double.parse(this, (e) => null) != null;
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension RGBColor on Color {
  static Color fromRGB(String rgbString) {
    var tmp = rgbString.substring(4, rgbString.length - 1).split(",");
    return Color.fromARGB(255, int.parse(tmp[0]), int.parse(tmp[1]), int.parse(tmp[2]));
  }
}

import 'dart:ui';

extension Number on num {
  bool isIn(a, b) {
    return this <= b && this >= a;
  } // 区间判断
}

extension Str on String {
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
    return Color.fromARGB(
        255, int.parse(tmp[0]), int.parse(tmp[1]), int.parse(tmp[2]));
  }
}

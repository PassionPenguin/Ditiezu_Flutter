import 'dart:ui';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension RGBColor on Color{
  static Color fromRGB(String rgbString) {
    var tmp = rgbString.substring(4, rgbString.length - 1).split(",");
    return Color.fromARGB(255, int.parse(tmp[0]), int.parse(tmp[1]), int.parse(tmp[2]));
  }
}
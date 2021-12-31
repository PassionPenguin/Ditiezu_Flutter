import 'package:flutter/cupertino.dart';
import 'package:palette_generator/palette_generator.dart';

Future<PaletteGenerator> generatePalette(ImageProvider image) async {
  var paletteGenerator = await PaletteGenerator.fromImageProvider(image);
  return paletteGenerator;
}

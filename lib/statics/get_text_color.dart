import 'package:flutter/material.dart';

class ColorMethods {
  static Color getTextColor(int colorCode) {
    Map<String, int> rgbMap = {
      "R": ((colorCode - 0xFF000000) / (256 * 256)).ceil(),
      "G": (((colorCode - 0xFF000000) / 256) % 256).ceil(),
      "B": ((colorCode - 0xFF000000) % 256).ceil(),
    };

    // convert RGB to YIQ (사람 눈의 시신경 분포에 맞게 보정)
    var lightness =
        (rgbMap["R"]! * 0.299 + rgbMap["G"]! * 0.587 + rgbMap["B"]! * 0.114) /
            255;
    return lightness >= 0.5 ? Colors.black : Colors.white;
  }
}

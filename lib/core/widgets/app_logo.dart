import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;

  const AppLogo({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final logoAsset = isDarkMode
        ? 'assets/images/logo_light.png'
        : 'assets/images/logo_dark.png';

    return Image.asset(
      logoAsset,
      width: width,
      height: height,
    );
  }
}

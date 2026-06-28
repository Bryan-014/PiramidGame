import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFFD32F2F);
  static const primaryDark = Color(0xFFB71C1C);
  static const primaryDeep = Color(0xFF7F0000);
  static const gold = Color(0xFFFFC107);
  static const silver = Color(0xFF9E9E9E);
  static const bronze = Color(0xFFCD7F32);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark, primaryDeep],
  );
}

class AppRadius {
  const AppRadius._();

  static const xs = 8.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const pill = 999.0;
}

class AppSpacing {
  const AppSpacing._();

  static const screen = EdgeInsets.fromLTRB(16, 18, 16, 28);
  static const card = EdgeInsets.all(16);
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> soft([Color color = Colors.black]) => [
        BoxShadow(
          color: color.withOpacity(.05),
          blurRadius: 14,
          offset: const Offset(0, 7),
        ),
      ];

  static List<BoxShadow> primary() => [
        BoxShadow(
          color: AppColors.primary.withOpacity(.22),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];
}

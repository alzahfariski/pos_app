import 'package:flutter/material.dart';

class AppColors {
  // Primary Reference: 0xFF0029C6
  static const Color primary50 = Color(0xFFE6EBFA);
  static const Color primary100 = Color(0xFFC0CDf2);
  static const Color primary200 = Color(0xFF99AFEA);
  static const Color primary300 = Color(0xFF7391E2);
  static const Color primary400 = Color(0xFF4D73DA);
  static const Color primary500 = Color(0xFF0029C6);
  static const Color primary600 = Color(0xFF0023B2);
  static const Color primary700 = Color(0xFF001D9F);
  static const Color primary800 = Color(0xFF00178B);
  static const Color primary900 = Color(0xFF001177);

  // Neutral Reference: 0xFF6B7280
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // Success Reference: 0xFF32B51E
  static const Color success50 = Color(0xFFEAF8E8);
  static const Color success100 = Color(0xFFCBEDC6);
  static const Color success200 = Color(0xFFACE2A4);
  static const Color success300 = Color(0xFF8DD782);
  static const Color success400 = Color(0xFF6ECC60);
  static const Color success500 = Color(0xFF32B51E);
  static const Color success600 = Color(0xFF2D9A19);
  static const Color success700 = Color(0xFF247F15);
  static const Color success800 = Color(0xFF1B6410);
  static const Color success900 = Color(0xFF12480B);

  // Info Reference: 0xFF0472D3
  static const Color info50 = Color(0xFFE6F1FB);
  static const Color info100 = Color(0xFFC0DBF4);
  static const Color info200 = Color(0xFF9AC6EE);
  static const Color info300 = Color(0xFF74B0E8);
  static const Color info400 = Color(0xFF4E9BE1);
  static const Color info500 = Color(0xFF0472D3);
  static const Color info600 = Color(0xFF0462B9);
  static const Color info700 = Color(0xFF03519E);
  static const Color info800 = Color(0xFF024184);
  static const Color info900 = Color(0xFF013069);

  // Warning Reference: 0xFFFFAA02
  static const Color warning50 = Color(0xFFFFF7E6);
  static const Color warning100 = Color(0xFFFFEABF);
  static const Color warning200 = Color(0xFFFFDE99);
  static const Color warning300 = Color(0xFFFFD173);
  static const Color warning400 = Color(0xFFFFC54D);
  static const Color warning500 = Color(0xFFFFAA02);
  static const Color warning600 = Color(0xFFDB9202);
  static const Color warning700 = Color(0xFFB77901);
  static const Color warning800 = Color(0xFF936101);
  static const Color warning900 = Color(0xFF7A5101);

  // Danger Reference: 0xFFD62619
  static const Color danger50 = Color(0xFFFBE9E8);
  static const Color danger100 = Color(0xFFF5C8C5);
  static const Color danger200 = Color(0xFFEFA7A2);
  static const Color danger300 = Color(0xFFE9867F);
  static const Color danger400 = Color(0xFFE3655C);
  static const Color danger500 = Color(0xFFD62619);
  static const Color danger600 = Color(0xFFB52015);
  static const Color danger700 = Color(0xFF941A11);
  static const Color danger800 = Color(0xFF73140D);
  static const Color danger900 = Color(0xFF520E09);

  // Aliases for easier use
  static const Color success = success500;
  static const Color info = info500;
  static const Color warning = warning500;
  static const Color error = danger500;

  // Background Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = neutral50;
  static const Color surface = white;
  static const Color scaffoldBackground = neutral100;

  // Text Colors
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral600;
  static const Color textDisabled = neutral400;
  static const Color textInverse = white;

  // Button Colors
  static const Color buttonPrimary = primary500;
  static const Color buttonSecondary = neutral200;
  static const Color buttonDisabled = neutral300;

  // Border Colors
  static const Color border = neutral300;
  static const Color borderFocus = primary500;
  static const Color borderError = danger500;

  // Other
  static const Color divider = neutral200;
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x80000000);
}

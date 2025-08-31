import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'TikTokSans',
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,

  // 🎨 Màu chủ đạo
  primaryColor: const Color(0xFF182145),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF182145),
    brightness: Brightness.light,
    primary: const Color(0xFF182145),
    onPrimaryContainer: const Color.fromARGB(255, 21, 38, 114),
    secondary: const Color(0xFFeb7816),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    error: Colors.redAccent,
  ),

  // 🌐 AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF182145),
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // 📝 Text
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
        fontFamily: 'TikTokSans',
        color: Color(0xFF182145),
        fontSize: 28,
        fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(
        color: Color(0xFF182145), fontSize: 22, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(
        color: Color(0xFF333333), fontSize: 16, fontWeight: FontWeight.normal),
    bodyMedium: TextStyle(
        color: Color(0xFF555555), fontSize: 14, fontWeight: FontWeight.normal),
    labelLarge: TextStyle(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
  ),

  // 🔘 Nút chính
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFeb7816), // nút cam nổi bật
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
      overlayColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: const Color(0xFFeb7816),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ).copyWith(
      overlayColor: WidgetStateProperty.all(
        const Color(0xFF182145)
            .withAlpha((0.1 * 255).toInt()), // hiệu ứng nhấn navy nhạt
      ),
    ),
  ),
  // ✏️ Input
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade100,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF182145), width: 2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    hintStyle: TextStyle(color: Colors.grey.shade500),
    labelStyle: const TextStyle(color: Color(0xFF182145)),
  ),

  // 🖼 Icon
  iconTheme: const IconThemeData(color: Colors.black),
);

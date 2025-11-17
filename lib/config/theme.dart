import 'package:flutter/material.dart';

/// KFC 应用主题配置 - 米白配色方案
class AppTheme {
  // 配色方案
  static const Color primaryBackground = Color(0xFFF5F5F0); // 主背景 米白色
  static const Color cardBackground = Color(0xFFFFFFFF); // 卡片背景 纯白
  static const Color lightBackground = Color(0xFFFEFEE8); // 浅米色背景
  static const Color codeBackground = Color(0xFFF8F8F8); // 代码背景
  
  static const Color textPrimary = Color(0xFF2C2C2C); // 文字主色 深灰
  static const Color textSecondary = Color(0xFF8B8B8B); // 文字副色 中灰
  static const Color textTertiary = Color(0xFFB8B8B8); // 文字三级色 浅灰
  
  static const Color accentColor = Color(0xFF4A90E2); // 强调色 蓝色
  static const Color borderColor = Color(0xFFE5E5E0); // 边框色 米白边框
  static const Color dividerColor = Color(0xFFF0F0EB); // 分割线色
  
  static const Color errorBackground = Color(0xFFFFF5F5); // 错误提示背景 淡红
  static const Color errorText = Color(0xFFE53935); // 错误文字
  
  static const Color successColor = Color(0xFF4CAF50); // 成功色
  static const Color warningColor = Color(0xFFFF9800); // 警告色

  /// 创建浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: accentColor,
        surface: primaryBackground,
        onSurface: textPrimary,
        error: errorText,
      ),
      scaffoldBackgroundColor: primaryBackground,
      
      // AppBar 主题
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textPrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card 主题
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // 图标按钮主题
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // 文字主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textTertiary),
      ),
    );
  }
}

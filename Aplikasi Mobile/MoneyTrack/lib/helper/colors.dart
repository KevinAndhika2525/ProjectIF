import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color lightGreyCard;
  final Color lightBlueCard;
  final Color balanceCard;
  final Color filterChip;
  final Color dateHeader;
  final Color unselectedChip;
  final Color appBarColor;
  final Color scaffoldBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color badge;

  const AppColors({
    required this.lightGreyCard,
    required this.lightBlueCard,
    required this.balanceCard,
    required this.filterChip,
    required this.dateHeader,
    required this.unselectedChip,
    required this.appBarColor,
    required this.scaffoldBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.badge,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? lightGreyCard,
    Color? lightBlueCard,
    Color? balanceCard,
    Color? filterChip,
    Color? dateHeader,
    Color? unselectedChip,
    Color? appBarColor,
    Color? scaffoldBackground,
    Color? textPrimary,
    Color? textSecondary,
    Color? badge,
  }) {
    return AppColors(
      lightGreyCard: lightGreyCard ?? this.lightGreyCard,
      lightBlueCard: lightBlueCard ?? this.lightBlueCard,
      balanceCard: balanceCard ?? this.balanceCard,
      filterChip: filterChip ?? this.filterChip,
      dateHeader: dateHeader ?? this.dateHeader,
      unselectedChip: unselectedChip ?? this.unselectedChip,
      appBarColor: appBarColor ?? this.appBarColor,
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      badge: badge ?? this.badge,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      lightGreyCard: Color.lerp(lightGreyCard, other.lightGreyCard, t)!,
      lightBlueCard: Color.lerp(lightBlueCard, other.lightBlueCard, t)!,
      balanceCard: Color.lerp(balanceCard, other.balanceCard, t)!,
      filterChip: Color.lerp(filterChip, other.filterChip, t)!,
      dateHeader: Color.lerp(dateHeader, other.dateHeader, t)!,
      unselectedChip: Color.lerp(unselectedChip, other.unselectedChip, t)!,
      appBarColor: Color.lerp(appBarColor, other.appBarColor, t)!,
      scaffoldBackground: Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      badge: Color.lerp(badge, other.badge, t)!,
    );
  }

  // Light Theme Colors
  static const light = AppColors(
    lightGreyCard: Color(0xFFF5F5F5),
    lightBlueCard: Color(0xFFE3F2FD),
    balanceCard: Color(0xFFF5F5F5),
    filterChip: Color(0xFFE3F2FD),
    dateHeader: Color(0xFFEEEEEE),
    unselectedChip: Color(0xFFE0E0E0),
    appBarColor: Color(0xFF2196F3),
    scaffoldBackground: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF212121),
    textSecondary: Color(0xFF757575),
    badge: Color(0xFF7AC3FF),
  );

  // Dark Theme Colors
  static const dark = AppColors(
    lightGreyCard: Color(0xFF424242),
    lightBlueCard: Color(0xFF263238),
    balanceCard: Color(0xFF144617),
    filterChip: Color(0xFF232323),
    dateHeader: Color(0xFF616161),
    unselectedChip: Color(0xFF616161),
    appBarColor: Color(0xFF1E1E1E),
    scaffoldBackground: Color(0xFF121212),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFBDBDBD),
    badge: Color(0xFF0E283D),
  );
}
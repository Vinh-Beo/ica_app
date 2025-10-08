import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';
import 'package:ica_app/src/utils/ext/app_font_sizes.dart';

extension AppTextExtension on BuildContext {
//  button,
//   header,
//   text,
//   body,
//   body2,
//   bar,
//   description,
//   title,
//   subTitle

  TextTheme textTheme() => Theme.of(this).textTheme;

  TextStyle? headerStyle() => textTheme().headline6;

  TextStyle? bodyTextStyle() => textTheme().bodyText2;

  TextStyle? buttonTextStyle() => bodyTextStyle()?.copyWith(fontSize: AppFontSize.size14, fontWeight: FontWeight.w600);

  TextStyle? bodyTextPrimaryStyle() =>
      textTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, color: AppColors.colorPrimary);

  TextStyle? bodyTextAccentStyle() =>
      textTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, color: AppColors.colorAccent);

  TextStyle? body3TextStyle() =>
      textTheme().bodyText2?.copyWith(fontWeight: FontWeight.w400, color: AppColors.colorTextSecond);

  TextStyle? body2TextStyle() => textTheme().bodyText2?.copyWith(
        fontWeight: FontWeight.w400,
      );

  TextStyle? body1TextStyle() => textTheme().bodyText2?.copyWith(color: AppColors.colorTextPrimary);

  TextStyle? title1TextStyle() =>
      textTheme().bodyText2?.copyWith(fontWeight: FontWeight.w700, color: AppColors.colorTextPrimary);

  TextStyle? subtitleTextStyle() =>
      textTheme().bodyText1?.copyWith(fontWeight: FontWeight.w400, color: AppColors.colorTabInActive);
}

/// Black text style - w900
TextStyle blackTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.w900,
      fontFamily: fontFamily,
    );

/// Extra-bold text style - w800
TextStyle extraBoldTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.w800,
      fontFamily: fontFamily,
    );

/// Bold text style - w700
TextStyle boldTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
    );

/// Semi-bold text style - w600
TextStyle semiBoldTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.w600,
      fontFamily: fontFamily,
    );

/// Medium text style - w500
TextStyle mediumTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.w500,
      fontFamily: fontFamily,
    );

/// Normal text style - w400
TextStyle normalTextStyle(
  double size, {
  Color? color,
  double? height = 1.1,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.normal,
      fontFamily: fontFamily,
    );

/// Light text style - w300
TextStyle lightTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.w300,
      fontFamily: fontFamily,
    );

/// Extra-light text style - w200
TextStyle extraLightTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    thinTextStyle(size, color: color, height: height).copyWith(
      fontWeight: FontWeight.w200,
      fontFamily: fontFamily,
    );

/// Thin text style - w100
TextStyle thinTextStyle(
  double size, {
  Color? color,
  double? height,
  String? fontFamily,
}) =>
    TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w100,
      fontFamily: fontFamily,
      color: color,
      height: height,
    );

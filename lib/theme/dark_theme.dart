// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(backgroundColor: Colors.black),
    colorScheme: ColorScheme.dark(
        background: Colors.black,
        primary: Colors.grey.shade900,
        secondary: Colors.grey.shade800),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
    ));

import 'package:fiit_mtaa_fe/pages/games.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiit_mtaa_fe/providers/auth.dart';
import 'package:fiit_mtaa_fe/providers/account.dart';
import 'package:fiit_mtaa_fe/providers/game.dart';
import 'pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Mafia',
        routes: {
          '/games': (context) => const Games(),
        },
        theme: _buildTheme(),
        home: const Login(),
      )
    );
  }
}

ThemeData _buildTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: _colorScheme,
    primaryColor: primary,
    scaffoldBackgroundColor: surface,
    cardColor: secondary,
    errorColor: error,
    buttonTheme: const ButtonThemeData(
      colorScheme: _colorScheme,
      textTheme: ButtonTextTheme.normal,
    ),
  );
}

const ColorScheme _colorScheme = ColorScheme(
  primary: primary,
  secondary: secondary,
  surface: surface,
  background: background,
  error: error,
  onPrimary: onPrimary,
  onSecondary: onSecondary,
  onSurface: onSurface,
  onBackground: onBackground,
  onError: onError,
  brightness: Brightness.light,
);

const Color primary = Colors.black87;
const Color secondary = Colors.white24;
const Color surface = Colors.white;
const Color background = Colors.white;
const Color error = Colors.red;
const Color onPrimary = Colors.white;
const Color onSecondary = Colors.white;
const Color onSurface = Colors.black87;
const Color onBackground = Colors.black87;
const Color onError = Colors.white;

const defaultLetterSpacing = 0.03;
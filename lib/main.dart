import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_tutor/auth/login_screen.dart';
import 'package:urban_tutor/screens/home_page.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MyApp(token: token));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Tutor',
      theme: theme,
      home: token == null || JwtDecoder.isExpired(token!)
          ? const LoginScreen()
          : HomePage(token: token!),
    );
  }
}
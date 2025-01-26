import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_tutor/services/auth_service.dart';
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
  
  String? token = await AuthService.isTokenValid() 
    ? await AuthService.getToken() 
    : null;

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
      home: token != null ? HomePage(token: token!) : const LoginScreen(),
    );
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_tutor/notes_provider.dart';
import 'package:urban_tutor/services/auth_service.dart';
import 'package:urban_tutor/auth/login_screen.dart';
import 'package:urban_tutor/screens/home_page.dart';
import 'package:provider/provider.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo, brightness: Brightness.light),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDdvXRmXOK7N8osGoh3DoMI6XFaov3zgUc",
            authDomain: "urban-tutor-99377.firebaseapp.com",
            projectId: "urban-tutor-99377",
            storageBucket: "urban-tutor-99377.firebasestorage.app",
            messagingSenderId: "803971522773",
            appId: "1:803971522773:web:edf0336f3a5cbd00a7025c"));
  } else {
    Firebase.initializeApp();
  }

  String? token =
      await AuthService.isTokenValid() ? await AuthService.getToken() : null;

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => NotesProvider()),
    ], child: MyApp(token: token)),
  );
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

/* Always remember to change firebase directory through running flutterfire configure */
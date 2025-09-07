import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Your existing imports
import 'package:urban_tutor/providers/auth_provider.dart';
import 'package:urban_tutor/providers/notes_provider.dart';
import 'package:urban_tutor/providers/filter_provider.dart';
import 'package:urban_tutor/providers/theme_provider.dart';
import 'package:urban_tutor/services/auth_service_ns.dart';
import 'package:urban_tutor/auth/login_screen_ns.dart';
import 'package:urban_tutor/screens/home_page.dart';

// New imports for tutor functionality
import 'package:urban_tutor/providers/tutor_provider.dart';
import 'package:urban_tutor/utils/app_colors.dart';
import 'package:urban_tutor/utils/theme_config.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ➊ Load environment variables for Cloudinary
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    if (kDebugMode) {
      print('Warning: .env file not found. Cloudinary features may not work.');
    }
  }

  // ➋ Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDdvXRmXOK7N8osGoh3DoMI6XFaov3zgUc",
        authDomain: "urban-tutor-99377.firebaseapp.com",
        projectId: "urban-tutor-99377",
        storageBucket: "urban-tutor-99377.firebasestorage.app",
        messagingSenderId: "803971522773",
        appId: "1:803971522773:web:edf0336f3a5cbd00a7025c"
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // ➌ Configure Cloudinary SDK
  try {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    if (cloudName != null && cloudName.isNotEmpty) {
      CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
        cloudName: cloudName,
      );
      if (kDebugMode) {
        print('Cloudinary configured with cloud name: $cloudName');
      }
    } else {
      if (kDebugMode) {
        print('Warning: CLOUDINARY_CLOUD_NAME not found in .env file');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error configuring Cloudinary: $e');
    }
  }

  // ➍ Check existing token
  String? token = await AuthServiceNs.isTokenValid() 
      ? await AuthServiceNs.getToken() 
      : null;

  runApp(
    MultiProvider(
      providers: [
        // Theme provider should be first
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Your existing providers
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        
        // New provider for tutor functionality
        ChangeNotifierProvider(create: (_) => TutorProvider()),
      ],
      child: MyApp(token: token),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Urban Tutor',
          themeMode: themeProvider.themeMode,
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          home: token != null ? HomePage(token: token!) : const LoginScreen(),
          
          // Optional: Add named routes for better navigation
          routes: {
            '/home': (context) => HomePage(token: token ?? ''),
            '/login': (context) => const LoginScreen(),
          },
        );
      },
    );
  }
}

/* 
 * Always remember to change firebase directory through running flutterfire configure 
 * 
 * New additions for Cloudinary integration:
 * 1. dotenv for environment variables
 * 2. CloudinaryContext initialization
 * 3. TutorProvider for tutor management
 * 4. Educational color scheme with dark mode
 * 5. Error handling for missing .env file
 * 6. Theme provider integration
 */

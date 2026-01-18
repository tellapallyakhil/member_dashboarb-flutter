import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCorDUb8RGUcd85oqvNzJq6Ou64xckNOv8",
        authDomain: "repo-14bf7.firebaseapp.com",
        projectId: "repo-14bf7",
        storageBucket: "repo-14bf7.firebasestorage.app",
        messagingSenderId: "1046905420976",
        appId: "1:1046905420976:web:webappid",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Member Dashboard',
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}

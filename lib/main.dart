import 'package:flutter/material.dart';
import 'package:onde_comer/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OndeComerApp());
}

class OndeComerApp extends StatelessWidget {
  const OndeComerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onde Comer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEB5B2A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF7),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF7F3EE),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

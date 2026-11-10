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
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DBE6A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1714),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101B18),
          foregroundColor: Color(0xFFF1F9F4),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF17201D),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF17201D),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1D2C27),
          hintStyle: TextStyle(color: Color(0xFFCCE7D7)),
          labelStyle: TextStyle(color: Color(0xFFF1F9F4)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4A7C65)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF59D38A)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2DBE6A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:smart_calc/screens/draw_calculator_screen.dart';
import 'package:smart_calc/screens/home_screen.dart';
import 'package:smart_calc/screens/splash_screen.dart';
import 'package:smart_calc/screens/voice_calculator_screen.dart';
import 'package:smart_calc/screens/step_calculator_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String draw = '/draw';
  static const String voice = '/voice';
  static const String stepByStep = '/step-by-step';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      draw: (context) => const DrawCalculatorScreen(),
      voice: (context) => const VoiceCalculatorScreen(),
      stepByStep: (context) => const StepCalculatorScreen(),
    };
  }
}
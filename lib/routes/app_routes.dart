import 'package:flutter/material.dart';
import 'package:smart_calc/screens/draw_calculator_screen.dart';
import 'package:smart_calc/screens/home_screen.dart';
import 'package:smart_calc/screens/splash_screen.dart';
import 'package:smart_calc/screens/voice_calculator_screen.dart';
//import 'package:smart_calc/screens/step_calculator_screen.dart';
import '../screens/graph_screen.dart';
import '../screens/history_screen.dart';
import '../screens/conversion_screen.dart';
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String drawCalculator = '/draw-calculator';
  static const String voiceCalculator = '/voice-calculator';
  static const String graph = '/graph';
  static const String history = '/history';
  static const String conversion = '/conversion';
  static const String stepCalculator = '/step-calculator';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      drawCalculator: (context) => const DrawCalculatorScreen(),
      voiceCalculator: (context) => const VoiceCalculatorScreen(),
      graph: (context) => const GraphScreen(),
      history: (context) => const HistoryScreen(),
      conversion: (context) => const ConversionScreen(),
      //stepCalculator: (context) => const StepCalculatorScreen(),
    };
  }
}

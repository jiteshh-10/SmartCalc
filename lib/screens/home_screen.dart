import 'package:flutter/material.dart';
import 'package:smart_calc/routes/app_routes.dart';
import 'package:smart_calc/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCalc Home'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: const [
          FeatureCard(
            icon: Icons.draw,
            title: 'Draw to Calculate',
            route: AppRoutes.drawCalculator, // Make sure the route is correct
          ),
          FeatureCard(
            icon: Icons.mic,
            title: 'Voice Calculator',
            route: AppRoutes.voiceCalculator,
          ),
          FeatureCard(
            icon: Icons.graphic_eq,
            title: 'Graph',
            route: AppRoutes.graph,
          ),
          FeatureCard(
            icon: Icons.transform,
            title: 'Conversion',
            route: AppRoutes.conversion,
          ),
          FeatureCard(
            icon: Icons.history,
            title: 'History',
            route: AppRoutes.history,
          ),
        ],
      ),
    );
  }
}

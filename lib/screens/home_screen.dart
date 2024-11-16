import 'package:flutter/material.dart';
import 'package:smart_calc/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calculate_rounded),
            SizedBox(width: 8),
            Text('SmartCalc'),
          ],
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: const [
          FeatureCard(
            icon: Icons.draw,
            title: 'Draw to Calculate',
            route: '/draw',
          ),
          FeatureCard(
            icon: Icons.mic,
            title: 'Voice Input',
            route: '/voice',
          ),
          FeatureCard(
            icon: Icons.calculate,
            title: 'Step-by-Step',
            route: '/calculator',
          ),
          FeatureCard(
            icon: Icons.show_chart,
            title: 'Graph',
            route: '/graph',
          ),
          FeatureCard(
            icon: Icons.history,
            title: 'History',
            route: '/history',
          ),
          FeatureCard(
            icon: Icons.swap_horiz,
            title: 'Conversion',
            route: '/conversion',
          ),
        ],
      ),
    );
  }
}
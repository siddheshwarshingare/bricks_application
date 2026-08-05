import 'package:bricks_application/models/factory_model.dart';
import 'package:flutter/material.dart';

class DailyReportScreen extends StatelessWidget {
  final FactoryModel factory;

  const DailyReportScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Report")),
      body: const Center(child: Text("Coming Soon")),
    );
  }
}

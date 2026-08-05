import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/screens/reports/daily_report_screen.dart';
import 'package:bricks_application/screens/reports/monthly_report_screen.dart';
import 'package:bricks_application/screens/reports/profit_loss_screen.dart';
import 'package:bricks_application/screens/reports/weekly_report_screen.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  final FactoryModel factory;

  const ReportsScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.1,
          children: [
            reportCard(
              context,
              title: "Daily Report",
              icon: Icons.today,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DailyReportScreen(factory: factory),
                  ),
                );
              },
            ),

            reportCard(
              context,
              title: "Weekly Report",
              icon: Icons.date_range,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeeklyReportScreen(factory: factory),
                  ),
                );
              },
            ),

            reportCard(
              context,
              title: "Monthly Report",
              icon: Icons.calendar_month,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MonthlyReportScreen(factory: factory),
                  ),
                );
              },
            ),

            reportCard(
              context,
              title: "Profit & Loss",
              icon: Icons.account_balance_wallet,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfitLossScreen(factory: factory),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget reportCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/screens/reports/daily_report_screen.dart';
import 'package:bricks_application/screens/reports/monthly_report_screen.dart';
import 'package:bricks_application/screens/reports/profit_loss_screen.dart';
import 'package:bricks_application/screens/reports/stock_report_screen.dart';
import 'package:bricks_application/screens/reports/weekly_report_screen.dart';
import 'package:flutter/material.dart';

class ReportDashboardScreen extends StatelessWidget {
  final FactoryModel factory;

  const ReportDashboardScreen({super.key, required this.factory});

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
            // reportCard(
            //   context,
            //   title: "Daily Report",
            //   icon: Icons.today,
            //   color: Colors.orange,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => DailyReportScreen(factory: factory),
            //       ),
            //     );
            //   },
            // ),
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

            // reportCard(
            //   context,
            //   title: "Stock Report",
            //   icon: Icons.inventory_2,
            //   color: Colors.teal,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => StockReportScreen(factory: factory),
            //       ),
            //     );
            //   },
            // ),
            reportCard(
              context,
              title: "Customer Ledger",
              icon: Icons.people,
              color: Colors.red,
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Coming Soon")));
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: .15),
              child: Icon(icon, color: color, size: 28),
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

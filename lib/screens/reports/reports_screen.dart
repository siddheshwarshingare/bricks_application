import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/screens/reports/daily_report_screen.dart';
import 'package:bricks_application/screens/reports/monthly_report_screen.dart';
import 'package:bricks_application/screens/reports/profit_loss_screen.dart';
import 'package:bricks_application/screens/reports/weekly_report_screen.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  final FactoryModel factory;

  const ReportsScreen({super.key, required this.factory});

  static const Color primaryBlue = Color(0xff2563EB);
  static const Color backgroundColor = Color(0xffF5F7FB);
  static const Color textColor = Color(0xff111827);
  static const Color greyTextColor = Color(0xff6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Reports",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.05,

          children: [
            reportCard(
              context,
              title: "Daily Report",
              subtitle: "View daily activity",
              icon: Icons.today,
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
              subtitle: "View weekly summary",
              icon: Icons.date_range,
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
              subtitle: "View monthly summary",
              icon: Icons.calendar_month,
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
              subtitle: "View financial summary",
              icon: Icons.account_balance_wallet,
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
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),

            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),

          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // Icon
              Container(
                width: 62,
                height: 62,

                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.assessment,
                  color: primaryBlue,
                  size: 30,
                ),
              ),

              const SizedBox(height: 14),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: greyTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // Arrow
              // Container(
              //   padding: const EdgeInsets.all(6),

              //   decoration: BoxDecoration(
              //     color: primaryBlue.withOpacity(0.08),
              //     borderRadius: BorderRadius.circular(8),
              //   ),

              //   child: const Icon(
              //     Icons.arrow_forward,
              //     color: primaryBlue,
              //     size: 18,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

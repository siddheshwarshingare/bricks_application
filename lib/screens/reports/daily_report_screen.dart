import 'package:bricks_application/models/daily_report_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/daily_report_repository.dart';
import 'package:flutter/material.dart';

class DailyReportScreen extends StatelessWidget {
  final FactoryModel factory;

  const DailyReportScreen({super.key, required this.factory});
  static const Color primaryBlue = Color(0xff2563EB);
  @override
  Widget build(BuildContext context) {
    final repository = DailyReportRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daily Report",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: primaryBlue,
      ),
      body: StreamBuilder<DailyReportModel>(
        stream: repository.getTodayReport(factory.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final report = snapshot.data!;

          final profit =
              report.sales - report.salaryExpense - report.materialExpense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    summaryCard(
                      "Production",
                      "${report.production.toStringAsFixed(0)} Bricks",
                      Icons.factory,
                      Colors.orange,
                    ),

                    summaryCard(
                      "Bricks Sold",
                      report.bricksSold.toStringAsFixed(0),
                      Icons.shopping_cart,
                      Colors.green,
                    ),

                    summaryCard(
                      "Sales",
                      "₹${report.sales.toStringAsFixed(0)}",
                      Icons.currency_rupee,
                      Colors.blue,
                    ),

                    summaryCard(
                      "Collection",
                      "₹${report.collection.toStringAsFixed(0)}",
                      Icons.payments,
                      Colors.teal,
                    ),

                    summaryCard(
                      "Salary",
                      "₹${report.salaryExpense.toStringAsFixed(0)}",
                      Icons.people,
                      Colors.deepOrange,
                    ),

                    summaryCard(
                      "Material",
                      "₹${report.materialExpense.toStringAsFixed(0)}",
                      Icons.inventory,
                      Colors.brown,
                    ),

                    summaryCard(
                      "Pending",
                      "₹${report.pending.toStringAsFixed(0)}",
                      Icons.account_balance_wallet,
                      Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                Card(
                  elevation: 4,
                  color: Colors.green.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Text(
                          "Profit Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Divider(),

                        row("Sales", report.sales),

                        row("Salary Expense", -report.salaryExpense),

                        row("Material Expense", -report.materialExpense),

                        const Divider(thickness: 1.5),

                        row("Net Profit", profit, isTotal: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget row(String title, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              color: value >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

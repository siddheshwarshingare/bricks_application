import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/weekly_report_repository.dart';
import 'package:flutter/material.dart';

class WeeklyReportScreen extends StatelessWidget {
  final FactoryModel factory;

  const WeeklyReportScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    final repository = WeeklyReportRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weekly Report",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xff2563EB),
      ),
      body: StreamBuilder(
        stream: repository.getWeeklyReport(factory.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final report = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              reportTile(
                "Bricks Produced",
                report.production.toStringAsFixed(0),
                Icons.factory,
                Colors.orange,
              ),

              reportTile(
                "Bricks Sold",
                report.bricksSold.toStringAsFixed(0),
                Icons.shopping_cart,
                Colors.green,
              ),

              reportTile(
                "Sales",
                "₹${report.sales.toStringAsFixed(0)}",
                Icons.currency_rupee,
                Colors.green,
              ),

              reportTile(
                "Collection",
                "₹${report.collection.toStringAsFixed(0)}",
                Icons.payments,
                Colors.blue,
              ),

              reportTile(
                "Salary Expense",
                "₹${report.salaryExpense.toStringAsFixed(0)}",
                Icons.people,
                Colors.red,
              ),

              reportTile(
                "Material Expense",
                "₹${report.materialExpense.toStringAsFixed(0)}",
                Icons.inventory,
                Colors.brown,
              ),

              reportTile(
                "Pending Amount",
                "₹${report.pending.toStringAsFixed(0)}",
                Icons.account_balance_wallet,
                Colors.purple,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget reportTile(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}

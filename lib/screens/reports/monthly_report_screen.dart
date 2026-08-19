import 'package:bricks_application/models/daily_report_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/monthly_report_model.dart';
import 'package:bricks_application/repositories/monthly_report_repository.dart';
import 'package:flutter/material.dart';

class MonthlyReportScreen extends StatelessWidget {
  final FactoryModel factory;

  MonthlyReportScreen({super.key, required this.factory});

  final MonthlyReportRepository repository = MonthlyReportRepository();

  Widget reportTile(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Monthly Report",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xff2563EB),
      ),
      body: StreamBuilder<MonthlyReportModel>(
        stream: repository.getMonthlyReport(factory.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final report = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              reportTile(
                "Production",
                "${report.production.toStringAsFixed(0)} Bricks",
                Icons.factory,
                Colors.orange,
              ),

              reportTile(
                "Bricks Sold",
                "${report.bricksSold.toStringAsFixed(0)} Bricks",
                Icons.inventory,
                Colors.green,
              ),

              reportTile(
                "Sales",
                "₹${report.sales.toStringAsFixed(0)}",
                Icons.currency_rupee,
                Colors.blue,
              ),

              reportTile(
                "Collection",
                "₹${report.collection.toStringAsFixed(0)}",
                Icons.payments,
                Colors.teal,
              ),

              reportTile(
                "Salary Expense",
                "₹${report.salaryExpense.toStringAsFixed(0)}",
                Icons.people,
                Colors.deepPurple,
              ),

              reportTile(
                "Material Expense",
                "₹${report.materialExpense.toStringAsFixed(0)}",
                Icons.inventory_2,
                Colors.brown,
              ),

              reportTile(
                "Pending Amount",
                "₹${report.pending.toStringAsFixed(0)}",
                Icons.account_balance_wallet,
                Colors.red,
              ),
            ],
          );
        },
      ),
    );
  }
}

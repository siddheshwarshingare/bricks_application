import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/monthly_report_model.dart';
import 'package:bricks_application/repositories/monthly_report_repository.dart';
import 'package:flutter/material.dart';

class ProfitLossScreen extends StatefulWidget {
  final FactoryModel factory;

  const ProfitLossScreen({super.key, required this.factory});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final MonthlyReportRepository repository = MonthlyReportRepository();
  DashboardFilter selectedFilter = DashboardFilter.today;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profit & Loss",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xff2563EB),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<DashboardFilter>(
              segments: const [
                ButtonSegment(
                  value: DashboardFilter.today,
                  label: Text("Today"),
                  icon: Icon(Icons.today),
                ),
                ButtonSegment(
                  value: DashboardFilter.thisWeek,
                  label: Text("Week"),
                  icon: Icon(Icons.date_range),
                ),
                ButtonSegment(
                  value: DashboardFilter.thisMonth,
                  label: Text("Month"),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: {selectedFilter},
              onSelectionChanged: (value) {
                setState(() {
                  selectedFilter = value.first;
                });
              },
              showSelectedIcon: false,
            ),
          ),
          Expanded(
            child: StreamBuilder<MonthlyReportModel>(
              stream: repository.getReport(widget.factory.id, selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No Data Found"));
                }

                final report = snapshot.data!;

                final totalExpense =
                    report.salaryExpense + report.materialExpense;

                final profit = report.sales - totalExpense;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      buildCard(
                        title: "Total Revenue",
                        value: "₹${report.sales.toStringAsFixed(0)}",
                        icon: Icons.currency_rupee,
                        color: Colors.green,
                      ),

                      const SizedBox(height: 15),

                      buildCard(
                        title: "Total Expense",
                        value: "₹${totalExpense.toStringAsFixed(0)}",
                        icon: Icons.money_off,
                        color: Colors.red,
                      ),

                      const SizedBox(height: 20),

                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Text(
                                "Expense Breakdown",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Divider(),

                              buildRow("Salary Expense", report.salaryExpense),

                              buildRow(
                                "Material Expense",
                                report.materialExpense,
                              ),

                              const Divider(),

                              buildRow(
                                "Total Expense",
                                totalExpense,
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: profit >= 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: profit >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              profit >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 45,
                              color: profit >= 0 ? Colors.green : Colors.red,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              profit >= 0 ? "Net Profit" : "Net Loss",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: profit >= 0 ? Colors.green : Colors.red,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "₹${profit.abs().toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: profit >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Text(
                                "Business Summary",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Divider(),

                              buildRow("Pending Collection", report.pending),

                              buildRow("Bricks Sold", report.bricksSold),

                              buildRow("Production", report.production),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(String title, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

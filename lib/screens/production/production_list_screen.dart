import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/screens/production/add_production_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductionListScreen extends StatefulWidget {
  final FactoryModel factory;

  const ProductionListScreen({super.key, required this.factory});

  @override
  State<ProductionListScreen> createState() => _ProductionListScreenState();
}

class _ProductionListScreenState extends State<ProductionListScreen> {
  final ProductionRepository repository = ProductionRepository();
  DashboardFilter selectedFilter = DashboardFilter.thisWeek;
  final TextEditingController searchController = TextEditingController();

  Map<String, double> calculateSummary(List<ProductionModel> productions) {
    double totalProduction = 0;
    double totalEarned = 0;
    double totalPaid = 0;
    double totalReturned = 0;

    for (final production in productions) {
      totalProduction += production.bricksProduced.toDouble();
      totalEarned += production.salaryEarned;
      totalPaid += production.salaryPaid;
      totalReturned += production.cashReturned;
    }

    return {
      "production": totalProduction,
      "earned": totalEarned,
      "paid": totalPaid,
      "returned": totalReturned,
    };
  }

  void showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: DashboardFilter.values.map((filter) {
            return ListTile(
              leading: Icon(
                selectedFilter == filter
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: Colors.orange,
              ),
              title: Text(filter.name),
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });

                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  String search = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.factory.name} Production")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductionScreen(factory: widget.factory),
            ),
          );
        },
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Worker",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: showFilterBottomSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedFilter.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<ProductionModel>>(
              stream: repository.getProductionsByFilter(
                widget.factory.id,
                selectedFilter,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final productions = snapshot.data ?? [];

                final filtered = productions.where((production) {
                  return production.workerName.toLowerCase().contains(search);
                }).toList();
                final summary = calculateSummary(filtered);
                double totalProduction = 0;

                for (final production in filtered) {
                  totalProduction += production.bricksProduced.toDouble();
                }
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Production Found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(15),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // const Text(
                            //   "Total Production",
                            //   style: TextStyle(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // Text(
                            //   "${totalProduction.toStringAsFixed(0)} Bricks",
                            //   style: const TextStyle(
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.orange,
                            //   ),
                            // ),
                            Text(
                              "🧱 ${summary["production"]!.toStringAsFixed(0)} Bricks",
                            ),

                            Text(
                              "Final ₹${summary["earned"]!.toStringAsFixed(0)}",
                            ),

                            Text(
                              "Given₹${summary["paid"]!.toStringAsFixed(0)}",
                            ),

                            Text(
                              "Return₹${summary["returned"]!.toStringAsFixed(0)}",
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final production = filtered[index];

                          return Dismissible(
                            key: Key(production.id),
                            direction: DismissDirection.endToStart,

                            background: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Production"),
                                  content: const Text(
                                    "Delete this production record?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },

                            onDismissed: (_) async {
                              await repository.deleteProduction(
                                widget.factory.id,
                                production.id,
                              );

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Production Deleted"),
                                ),
                              );
                            },

                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.factory),
                                ),

                                title: Text(
                                  production.workerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   "Rate : ₹${production.ratePer1000.toStringAsFixed(0)} per 1000",
                                    // ),
                                    Text(
                                      "Bricks : ${production.bricksProduced}",
                                    ),
                                    Text(
                                      "📅 ${DateFormat('dd MMM yyyy').format(production.productionDate.toDate())}",
                                    ),
                                    Text("Remarks : ${production.remarks}"),
                                    Text(
                                      "Salary : ₹${production.salaryEarned.toStringAsFixed(0)} | Paid : ₹${production.salaryPaid.toStringAsFixed(0)} | Cash Returned : ₹${production.cashReturned.toStringAsFixed(0)}",
                                    ),
                                  ],
                                ),

                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddProductionScreen(
                                          factory: widget.factory,
                                          production: production,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

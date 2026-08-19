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

  Widget _infoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget summaryTile(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(.15),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),

              Text(
                value,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,

        title: const Text(
          "Production",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
      ),

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
                filled: true,
                fillColor: Colors.white,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                hintText: "Search Worker",
                prefixIcon: const Icon(Icons.search, color: Color(0xff2563EB)),
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
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.filter_alt_rounded,
                        color: Color(0xff2563EB),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Filter",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            selectedFilter.name,
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey,
                    ),
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
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          // const Text(
                          //   "Today's Summary",
                          //   style: TextStyle(
                          //     fontFamily: "Poppins",
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: summaryTile(
                                  Icons.grid_view_rounded,
                                  "Production",
                                  "${summary["production"]!.toStringAsFixed(0)}",
                                  const Color(0xff2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: summaryTile(
                                  Icons.currency_rupee,
                                  "Earned",
                                  "₹${summary["earned"]!.toStringAsFixed(0)}",
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: summaryTile(
                                  Icons.payments,
                                  "Paid",
                                  "₹${summary["paid"]!.toStringAsFixed(0)}",
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: summaryTile(
                                  Icons.reply,
                                  "Returned",
                                  "₹${summary["returned"]!.toStringAsFixed(0)}",
                                  Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
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

                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x11000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Date + Edit
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat("dd MMM yyyy").format(
                                            production.productionDate.toDate(),
                                          ),
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 13,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const Spacer(),

                                        IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddProductionScreen(
                                                      factory: widget.factory,
                                                      production: production,
                                                    ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xff2563EB),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      production.workerName,
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "${production.bricksProduced.toStringAsFixed(0)} Bricks",
                                      style: const TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: _infoTile(
                                            "Salary",
                                            "₹${production.salaryEarned.toStringAsFixed(0)}",
                                          ),
                                        ),

                                        Expanded(
                                          child: _infoTile(
                                            "Paid",
                                            "₹${production.salaryPaid.toStringAsFixed(0)}",
                                          ),
                                        ),

                                        Expanded(
                                          child: _infoTile(
                                            "Returned",
                                            "₹${production.cashReturned.toStringAsFixed(0)}",
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (production.remarks.isNotEmpty) ...[
                                      const SizedBox(height: 14),

                                      const Divider(),

                                      const SizedBox(height: 8),

                                      const Text(
                                        "Remarks",
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        production.remarks,
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
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

import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/material_model.dart';
import 'package:bricks_application/repositories/material_repository.dart';
import 'package:bricks_application/screens/materials/add_material_screen.dart';
import 'package:bricks_application/screens/materials/material_expense_list_screen.dart';
import 'package:bricks_application/screens/materials/material_usage_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MaterialListScreen extends StatefulWidget {
  final FactoryModel factory;

  const MaterialListScreen({super.key, required this.factory});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  final MaterialRepository repository = MaterialRepository();
  final TextEditingController searchController = TextEditingController();

  String search = '';
  DateTime? startDate;
  DateTime? endDate;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<bool?> deleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Material'),
        content: const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> chooseDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = picked;
          }
        } else {
          endDate = picked;
          if (startDate != null && picked.isBefore(startDate!)) {
            startDate = picked;
          }
        }
      });
    }
  }

  String dateText(DateTime? date) {
    if (date == null) return 'Any';
    return '${date.day}/${date.month}/${date.year}';
  }

  String stockKey(String name, String unit) =>
      '${name.trim().toLowerCase()}|${unit.trim().toLowerCase()}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'expense') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MaterialExpenseListScreen(factory: widget.factory),
                  ),
                );
              } else if (value == 'usage') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MaterialUsageScreen(factory: widget.factory),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'usage',
                child: Row(
                  children: [
                    Icon(Icons.remove_circle_outline),
                    SizedBox(width: 10),
                    Text('Record Material Usage'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'expense',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long),
                    SizedBox(width: 10),
                    Text('Material Expenses'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMaterialScreen(factory: widget.factory),
            ),
          );
        },
      ),
      body: StreamBuilder<List<MaterialModel>>(
        stream: repository.getMaterials(widget.factory.id),
        builder: (context, materialSnapshot) {
          if (materialSnapshot.hasError) {
            return Center(child: Text('${materialSnapshot.error}'));
          }

          if (!materialSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final materials = materialSnapshot.data!;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: repository.getMaterialUsages(widget.factory.id),
            builder: (context, usageSnapshot) {
              if (usageSnapshot.hasError) {
                return Center(child: Text('${usageSnapshot.error}'));
              }

              if (!usageSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final stock = <String, double>{};
              final names = <String, String>{};
              final units = <String, String>{};
              final used = <String, double>{};

              for (final material in materials) {
                final key = stockKey(material.materialName, material.unit);

                stock[key] = (stock[key] ?? 0) + material.quantity;
                names[key] = material.materialName.trim();
                units[key] = material.unit.trim();
              }

              for (final doc in usageSnapshot.data!.docs) {
                final data = doc.data();
                final name = (data['materialName'] ?? '').toString().trim();
                final unit = (data['unit'] ?? '').toString().trim();
                final key = stockKey(name, unit);
                final amount = data['quantity'];

                if (amount is num) {
                  used[key] = (used[key] ?? 0) + amount.toDouble();
                }
              }

              for (final entry in used.entries) {
                stock[entry.key] = (stock[entry.key] ?? 0) - entry.value;
              }

              final filteredMaterials = materials.where((material) {
                final nameMatches = material.materialName
                    .toLowerCase()
                    .contains(search.toLowerCase());

                final date = material.purchaseDate.toDate();
                final start = startDate == null
                    ? null
                    : DateTime(
                        startDate!.year,
                        startDate!.month,
                        startDate!.day,
                      );
                final endExclusive = endDate == null
                    ? null
                    : DateTime(endDate!.year, endDate!.month, endDate!.day + 1);

                final afterStart = start == null || !date.isBefore(start);
                final beforeEnd =
                    endExclusive == null || date.isBefore(endExclusive);

                return nameMatches && afterStart && beforeEnd;
              }).toList();

              final stockKeys = stock.keys.toList()
                ..sort((a, b) => (names[a] ?? a).compareTo(names[b] ?? b));

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Material',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                  ),

                  // Current stock summary, independent of date filter.
                  SizedBox(
                    height: 150,
                    child: stockKeys.isEmpty
                        ? const Center(child: Text('No stock recorded yet'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: stockKeys.length,
                            itemBuilder: (context, index) {
                              final key = stockKeys[index];
                              final quantity = stock[key] ?? 0;
                              final unit = units[key] ?? '';

                              return SizedBox(
                                width: 175,
                                child: Card(
                                  color: quantity <= 0
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          names[key] ?? key,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${quantity.toStringAsFixed(2)} $unit',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: quantity <= 0
                                                ? Colors.red
                                                : Colors.green.shade800,
                                          ),
                                        ),
                                        Text(
                                          'Used: ${(used[key] ?? 0).toStringAsFixed(2)} $unit',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Purchase History Filter',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        OutlinedButton(
                          onPressed: () => chooseDate(isStart: true),
                          child: Text('From: ${dateText(startDate)}'),
                        ),
                        OutlinedButton(
                          onPressed: () => chooseDate(isStart: false),
                          child: Text('To: ${dateText(endDate)}'),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            startDate = null;
                            endDate = null;
                          }),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: filteredMaterials.isEmpty
                        ? const Center(child: Text('No Materials Found'))
                        : ListView.builder(
                            itemCount: filteredMaterials.length,
                            itemBuilder: (context, index) {
                              final material = filteredMaterials[index];
                              final date = material.purchaseDate.toDate();

                              return Dismissible(
                                key: Key(material.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  padding: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (_) => deleteDialog(),
                                onDismissed: (_) async {
                                  try {
                                    await repository.deleteMaterial(
                                      widget.factory.id,
                                      material.id,
                                    );

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${material.materialName} purchase deleted',
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Delete failed: $e'),
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  elevation: 3,
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange.shade100,
                                      child: const Icon(
                                        Icons.inventory,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    title: Text(
                                      material.materialName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Purchased: ${material.quantity} ${material.unit}',
                                        ),
                                        Text('Price: ₹${material.price}'),
                                        Text('Supplier: ${material.supplier}'),
                                        Text(
                                          'Purchase: ${date.day}/${date.month}/${date.year}',
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
                                            builder: (_) => AddMaterialScreen(
                                              factory: widget.factory,
                                              material: material,
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
          );
        },
      ),
    );
  }
}

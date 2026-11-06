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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete Material'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this material purchase?',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
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

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF202938),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  Widget _stockCard({
    required String name,
    required double quantity,
    required double used,
    required String unit,
  }) {
    final isLow = quantity <= 0;

    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLow ? Colors.red.shade100 : Colors.green.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLow ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 19,
                  color: isLow ? Colors.red : Colors.green.shade700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLow ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLow ? 'Out of stock' : 'In stock',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isLow ? Colors.red : Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF202938),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${quantity.toStringAsFixed(2)} $unit',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: isLow ? Colors.red : Colors.green.shade800,
            ),
          ),
          const Spacer(),
          Divider(color: Colors.grey.shade200, height: 15),
          Row(
            children: [
              Icon(
                Icons.trending_down,
                size: 14,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Used: ${used.toStringAsFixed(2)} $unit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateFilterButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF344054),
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 14),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _materialCard(MaterialModel material, DateTime date) {
    return Dismissible(
      key: Key(material.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 25),
            SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) => deleteDialog(),
      onDismissed: (_) async {
        try {
          await repository.deleteMaterial(widget.factory.id, material.id);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${material.materialName} purchase deleted'),
            ),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E6),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFFED8B24),
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.materialName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF202938),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit material',
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
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF3478D4),
                      size: 21,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _materialInfo(
                        'PURCHASED',
                        '${material.quantity} ${material.unit}',
                        Icons.scale_outlined,
                      ),
                    ),
                    Container(
                      height: 34,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _materialInfo(
                        'PRICE',
                        '₹${material.price}',
                        Icons.currency_rupee,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      material.supplier.isEmpty
                          ? 'Supplier not specified'
                          : material.supplier,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Purchase',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _materialInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: Colors.grey.shade600),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF202938),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202938),
        title: const Text(
          'Materials',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
                    Icon(Icons.remove_circle_outline, size: 20),
                    SizedBox(width: 10),
                    Text('Record Material Usage'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'expense',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 20),
                    SizedBox(width: 10),
                    Text('Material Expenses'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Material',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
                  // Search
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search materials...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF667085),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F6F8),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: const BorderSide(
                            color: Color(0xFF3478D4),
                            width: 1.4,
                          ),
                        ),
                      ),
                      onChanged: (value) => setState(() => search = value),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 16, bottom: 95),
                      children: [
                        // Current stock summary
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _sectionTitle(
                            'Current Stock',
                            subtitle: 'Available material quantity',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 175,
                          child: stockKeys.isEmpty
                              ? Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Text('No stock recorded yet'),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: stockKeys.length,
                                  itemBuilder: (context, index) {
                                    final key = stockKeys[index];
                                    final quantity = stock[key] ?? 0;
                                    final unit = units[key] ?? '';

                                    return _stockCard(
                                      name: names[key] ?? key,
                                      quantity: quantity,
                                      used: used[key] ?? 0,
                                      unit: unit,
                                    );
                                  },
                                ),
                        ),

                        const SizedBox(height: 24),

                        // Purchase history heading and filters
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _sectionTitle(
                            'Purchase History',
                            subtitle: 'View and manage material purchases',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: const Color(0xFFEAECF0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.filter_alt_outlined,
                                    color: Colors.blue.shade700,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 7),
                                  const Text(
                                    'Filter by purchase date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF344054),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      startDate = null;
                                      endDate = null;
                                    }),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _dateFilterButton(
                                    label: 'From: ${dateText(startDate)}',
                                    onPressed: () => chooseDate(isStart: true),
                                  ),
                                  _dateFilterButton(
                                    label: 'To: ${dateText(endDate)}',
                                    onPressed: () => chooseDate(isStart: false),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        if (filteredMaterials.isEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(vertical: 35),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 42,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'No Materials Found',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try changing your search or date filter.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...filteredMaterials.map((material) {
                            final date = material.purchaseDate.toDate();
                            return _materialCard(material, date);
                          }),
                      ],
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

import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/material_model.dart';
import 'package:bricks_application/repositories/material_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MaterialUsageScreen extends StatefulWidget {
  final FactoryModel factory;

  const MaterialUsageScreen({super.key, required this.factory});

  @override
  State<MaterialUsageScreen> createState() => _MaterialUsageScreenState();
}

class _MaterialUsageScreenState extends State<MaterialUsageScreen> {
  final MaterialRepository repository = MaterialRepository();
  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController();
  final remarksController = TextEditingController();

  String? selectedKey;
  DateTime usageDate = DateTime.now();
  bool saving = false;

  @override
  void dispose() {
    quantityController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: usageDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked != null && mounted) {
      setState(() => usageDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Material Usage')),
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

              for (final material in materials) {
                final key =
                    '${material.materialName.trim().toLowerCase()}|${material.unit.trim().toLowerCase()}';

                stock[key] = (stock[key] ?? 0) + material.quantity;
                names[key] = material.materialName.trim();
                units[key] = material.unit.trim();
              }

              for (final doc in usageSnapshot.data!.docs) {
                final data = doc.data();
                final name = (data['materialName'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase();
                final unit = (data['unit'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase();
                final key = '$name|$unit';
                final quantity = data['quantity'];

                if (quantity is num) {
                  stock[key] = (stock[key] ?? 0) - quantity.toDouble();
                }
              }

              final keys = stock.keys.toList()..sort();

              if (selectedKey != null && !stock.containsKey(selectedKey)) {
                selectedKey = null;
              }

              final available = selectedKey == null
                  ? 0.0
                  : stock[selectedKey!] ?? 0.0;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedKey,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Material',
                                border: OutlineInputBorder(),
                              ),
                              items: keys.map((key) {
                                return DropdownMenuItem(
                                  value: key,
                                  child: Text('${names[key]} (${units[key]})'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedKey = value);
                              },
                              validator: (value) =>
                                  value == null ? 'Select material' : null,
                            ),
                            const SizedBox(height: 16),

                            if (selectedKey != null)
                              Card(
                                color: Colors.green.shade50,
                                child: ListTile(
                                  title: const Text('Available Stock'),
                                  subtitle: Text(
                                    '${available.toStringAsFixed(2)} ${units[selectedKey]}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 12),
                            TextFormField(
                              controller: quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Quantity Used',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                final quantity = double.tryParse(
                                  value?.trim() ?? '',
                                );
                                if (quantity == null || quantity <= 0) {
                                  return 'Enter a valid quantity';
                                }
                                if (quantity > available) {
                                  return 'Only ${available.toStringAsFixed(2)} available';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            OutlinedButton.icon(
                              onPressed: selectDate,
                              icon: const Icon(Icons.calendar_month),
                              label: Text(
                                'Usage Date: ${usageDate.day}/${usageDate.month}/${usageDate.year}',
                              ),
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: remarksController,
                              decoration: const InputDecoration(
                                labelText: 'Remarks (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: Text(
                                  saving ? 'Saving...' : 'Save Usage',
                                ),
                                onPressed: saving
                                    ? null
                                    : () async {
                                        if (!formKey.currentState!.validate()) {
                                          return;
                                        }

                                        final key = selectedKey!;
                                        final currentStock = stock[key] ?? 0;
                                        final quantity = double.parse(
                                          quantityController.text.trim(),
                                        );

                                        if (quantity > currentStock) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Insufficient stock.',
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() => saving = true);

                                        try {
                                          await repository.addMaterialUsage(
                                            factoryId: widget.factory.id,
                                            materialName: names[key]!,
                                            unit: units[key]!,
                                            quantity: quantity,
                                            usageDate: usageDate,
                                            remarks: remarksController.text,
                                          );

                                          if (!mounted) return;

                                          quantityController.clear();
                                          remarksController.clear();

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Material usage saved.',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to save usage: $e',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() => saving = false);
                                          }
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
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

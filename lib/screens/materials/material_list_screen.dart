import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/material_model.dart';
import 'package:bricks_application/repositories/material_repository.dart';
import 'package:bricks_application/screens/materials/add_material_screen.dart';
import 'package:bricks_application/screens/materials/material_expense_list_screen.dart';
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

  String search = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<bool?> deleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Material"),
          content: const Text("Are you sure you want to delete this material?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Materials"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "expense") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MaterialExpenseListScreen(factory: widget.factory),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "expense",
                child: Row(
                  children: [
                    Icon(Icons.receipt_long),
                    SizedBox(width: 10),
                    Text("Material Expenses"),
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

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Material",
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

          Expanded(
            child: StreamBuilder<List<MaterialModel>>(
              stream: repository.getMaterials(widget.factory.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final materials = snapshot.data ?? [];

                final filteredMaterials = materials.where((material) {
                  return material.materialName.toLowerCase().contains(search);
                }).toList();

                if (filteredMaterials.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Materials Found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredMaterials.length,
                  itemBuilder: (context, index) {
                    final material = filteredMaterials[index];

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
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      confirmDismiss: (_) async {
                        return await deleteDialog();
                      },

                      onDismissed: (_) async {
                        await repository.deleteMaterial(
                          widget.factory.id,
                          material.id,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${material.materialName} Deleted"),
                          ),
                        );
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text(
                                "Quantity : ${material.quantity} ${material.unit}",
                              ),

                              Text("Price : ₹${material.price}"),

                              Text("Supplier : ${material.supplier}"),

                              Text(
                                "Purchase : ${material.purchaseDate.toDate().day}/${material.purchaseDate.toDate().month}/${material.purchaseDate.toDate().year}",
                              ),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

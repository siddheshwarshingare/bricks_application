import 'package:bricks_application/models/expense_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/material_expense_repository.dart';
import 'package:bricks_application/screens/materials/add_material_expense_screen.dart';
import 'package:flutter/material.dart';

class MaterialExpenseListScreen extends StatelessWidget {
  final FactoryModel factory;

  MaterialExpenseListScreen({super.key, required this.factory});

  final MaterialExpenseRepository repository = MaterialExpenseRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Material Expenses")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMaterialExpenseScreen(factory: factory),
            ),
          );
        },
      ),

      body: StreamBuilder<List<MaterialExpenseModel>>(
        stream: repository.getExpenses(factory.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Material Expenses"));
          }

          final expenses = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.inventory, color: Colors.orange),
                  ),

                  title: Text(
                    expense.materialName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₹${expense.amount.toStringAsFixed(0)}"),

                      Text(expense.note),

                      Text(
                        "${expense.expenseDate.toDate().day}/${expense.expenseDate.toDate().month}/${expense.expenseDate.toDate().year}",
                      ),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "edit") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddMaterialExpenseScreen(
                              factory: factory,
                              expense: expense,
                            ),
                          ),
                        );
                      }

                      if (value == "delete") {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete"),
                            content: const Text("Delete this expense?"),
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
                          ),
                        );

                        if (confirm == true) {
                          repository.deleteExpense(factory.id, expense.id);
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "edit", child: Text("Edit")),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

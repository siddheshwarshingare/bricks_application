import 'package:bricks_application/models/expense_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/material_expense_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMaterialExpenseScreen extends StatefulWidget {
  final FactoryModel factory;
  final MaterialExpenseModel? expense;

  const AddMaterialExpenseScreen({
    super.key,
    required this.factory,
    this.expense,
  });

  @override
  State<AddMaterialExpenseScreen> createState() =>
      _AddMaterialExpenseScreenState();
}

class _AddMaterialExpenseScreenState extends State<AddMaterialExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final MaterialExpenseRepository repository = MaterialExpenseRepository();

  late TextEditingController materialController;
  late TextEditingController amountController;
  late TextEditingController noteController;

  DateTime expenseDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    materialController = TextEditingController(
      text: widget.expense?.materialName ?? "",
    );

    amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? "",
    );

    noteController = TextEditingController(text: widget.expense?.note ?? "");

    if (widget.expense != null) {
      expenseDate = widget.expense!.expenseDate.toDate();
    }
  }

  @override
  void dispose() {
    materialController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expenseDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expenseDate = picked;
      });
    }
  }

  Future<void> saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = MaterialExpenseModel(
      id: widget.expense?.id ?? "",
      factoryId: widget.factory.id,
      materialName: materialController.text.trim(),
      amount: double.parse(amountController.text),
      note: noteController.text.trim(),
      expenseDate: Timestamp.fromDate(expenseDate),
      createdAt: widget.expense?.createdAt ?? Timestamp.now(),
    );

    if (widget.expense == null) {
      await repository.addExpense(expense);
    } else {
      await repository.updateExpense(expense);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.expense == null
              ? "Expense Added Successfully"
              : "Expense Updated Successfully",
        ),
      ),
    );

    Navigator.pop(context);
  }

  Widget textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Enter $label";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null
              ? "Add Material Expense"
              : "Edit Material Expense",
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              textField(controller: materialController, label: "Material Name"),

              textField(
                controller: amountController,
                label: "Amount",
                keyboardType: TextInputType.number,
              ),

              InkWell(
                onTap: selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Expense Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    "${expenseDate.day}/${expenseDate.month}/${expenseDate.year}",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              textField(controller: noteController, label: "Note", maxLines: 3),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.expense == null ? "Save Expense" : "Update Expense",
                  ),
                  onPressed: saveExpense,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

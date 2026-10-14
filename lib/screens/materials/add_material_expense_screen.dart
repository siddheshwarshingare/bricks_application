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

  // NEW
  String selectedCategory = "Other";

  // NEW
  final List<String> categories = [
    "Material",
    "Fuel",
    "Salary",
    "Electricity",
    "Transport",
    "Maintenance",
    "Rent",
    "Water",
    "Other",
  ];

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

      // Existing expenses without category will use Other
      selectedCategory = categories.contains(widget.expense!.category)
          ? widget.expense!.category
          : "Other";
    }
  }

  @override
  void dispose() {
    materialController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // DATE
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // SAVE EXPENSE
  // ------------------------------------------------------------

  Future<void> saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid amount"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final expense = MaterialExpenseModel(
      id: widget.expense?.id ?? "",

      factoryId: widget.factory.id,

      // We keep your existing field
      materialName: materialController.text.trim(),

      // NEW
      category: selectedCategory,

      amount: amount,

      note: noteController.text.trim(),

      expenseDate: Timestamp.fromDate(expenseDate),

      createdAt: widget.expense?.createdAt ?? Timestamp.now(),
    );

    try {
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
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save expense: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // TEXT FIELD
  // ------------------------------------------------------------

  Widget textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
          prefixIcon: Icon(icon),

          filled: true,
          fillColor: Colors.grey.shade50,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xff2563EB), width: 1.5),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // CATEGORY FIELD
  // ------------------------------------------------------------

  Widget categoryField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,

        decoration: InputDecoration(
          labelText: "Expense Category",
          prefixIcon: const Icon(Icons.category_rounded),

          filled: true,
          fillColor: Colors.grey.shade50,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),

        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),

        onChanged: (value) {
          if (value == null) return;

          setState(() {
            selectedCategory = value;
          });
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // DATE FIELD
  // ------------------------------------------------------------

  Widget dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: selectDate,
        borderRadius: BorderRadius.circular(14),

        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Expense Date",

            prefixIcon: const Icon(Icons.calendar_month_rounded),

            suffixIcon: const Icon(Icons.arrow_drop_down_rounded),

            filled: true,
            fillColor: Colors.grey.shade50,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),

          child: Text(
            "${expenseDate.day.toString().padLeft(2, '0')}/"
            "${expenseDate.month.toString().padLeft(2, '0')}/"
            "${expenseDate.year}",
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.expense != null;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          isEdit ? "Edit Expense" : "Add Expense",
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------------
              // HEADER
              // ------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff2563EB), Color(0xff3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff2563EB).withValues(alpha: .15),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit ? "Update Expense" : "New Factory Expense",

                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            widget.factory.name,

                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: "Poppins",
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Expense Details",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111827),
                ),
              ),

              const SizedBox(height: 15),

              // Expense Name
              textField(
                controller: materialController,
                label: "Expense Name",
                icon: Icons.receipt_long_rounded,
              ),

              // Category
              categoryField(),

              // Amount
              textField(
                controller: amountController,
                label: "Amount",
                icon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              // Date
              dateField(),

              // Note
              textField(
                controller: noteController,
                label: "Note",
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              // ------------------------------------------------
              // SAVE BUTTON
              // ------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: saveExpense,

                  icon: Icon(
                    isEdit ? Icons.update_rounded : Icons.save_rounded,
                  ),

                  label: Text(
                    isEdit ? "Update Expense" : "Save Expense",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

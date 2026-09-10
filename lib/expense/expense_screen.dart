import 'package:bricks_application/models/expense_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/material_expense_repository.dart';
import 'package:bricks_application/screens/materials/add_material_expense_screen.dart';
import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget {
  final FactoryModel factory;

  const ExpenseScreen({super.key, required this.factory});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final MaterialExpenseRepository repository = MaterialExpenseRepository();

  String selectedFilter = "Today";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Expenses",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.factory.name,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 11,
                color: Colors.white.withValues(alpha: .75),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Expense",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMaterialExpenseScreen(factory: widget.factory),
            ),
          );
        },
      ),

      body: StreamBuilder<List<MaterialExpenseModel>>(
        stream: repository.getExpenses(widget.factory.id),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading expenses\n${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          final allExpenses = snapshot.data ?? [];

          final filteredExpenses = _filterExpenses(allExpenses);

          final totalExpense = filteredExpenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(totalExpense),

                const SizedBox(height: 20),

                _buildFilter(),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Expense History",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff111827),
                      ),
                    ),

                    Text(
                      "${filteredExpenses.length} Expenses",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (filteredExpenses.isEmpty)
                  _buildEmptyState()
                else
                  ...filteredExpenses.map(
                    (expense) => _buildExpenseCard(expense),
                  ),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // FILTER DATA
  // ------------------------------------------------------------

  List<MaterialExpenseModel> _filterExpenses(
    List<MaterialExpenseModel> expenses,
  ) {
    final now = DateTime.now();

    if (selectedFilter == "All") {
      return expenses;
    }

    return expenses.where((expense) {
      final date = expense.expenseDate.toDate();

      final expenseDate = DateTime(date.year, date.month, date.day);

      final today = DateTime(now.year, now.month, now.day);

      if (selectedFilter == "Today") {
        return expenseDate == today;
      }

      if (selectedFilter == "Week") {
        final weekStart = today.subtract(Duration(days: today.weekday - 1));

        return !expenseDate.isBefore(weekStart);
      }

      if (selectedFilter == "Month") {
        return expenseDate.year == today.year &&
            expenseDate.month == today.month;
      }

      return true;
    }).toList();
  }

  // ------------------------------------------------------------
  // SUMMARY
  // ------------------------------------------------------------

  Widget _buildSummaryCard(double totalExpense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563EB).withValues(alpha: .20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                "$selectedFilter Expenses",
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            "₹${totalExpense.toStringAsFixed(2)}",
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            "Factory expenses",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FILTER
  // ------------------------------------------------------------

  Widget _buildFilter() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          _filterButton("Today"),
          _filterButton("Week"),
          _filterButton("Month"),
          _filterButton("All"),
        ],
      ),
    );
  }

  Widget _filterButton(String title) {
    final isSelected = selectedFilter == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xff6B7280),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EXPENSE CARD
  // ------------------------------------------------------------

  Widget _buildExpenseCard(MaterialExpenseModel expense) {
    final date = expense.expenseDate.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.red,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.materialName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111827),
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      "${date.day}/${date.month}/${date.year}",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                if (expense.note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    expense.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "- ₹${expense.amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xffDC2626),
                ),
              ),

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                onSelected: (value) {
                  if (value == "edit") {
                    _editExpense(expense);
                  } else if (value == "delete") {
                    _deleteExpense(expense);
                  }
                },
                itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 10),
                          Text("Edit"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 10),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EDIT
  // ------------------------------------------------------------

  void _editExpense(MaterialExpenseModel expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddMaterialExpenseScreen(factory: widget.factory, expense: expense),
      ),
    );
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> _deleteExpense(MaterialExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Expense"),
          content: Text("Delete ${expense.materialName} expense?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await repository.deleteExpense(widget.factory.id, expense.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Expense deleted successfully")),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xffEFF6FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: Color(0xff2563EB),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "No Expenses Found",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "No expenses found for $selectedFilter",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

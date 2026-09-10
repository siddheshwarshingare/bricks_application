import 'package:flutter/material.dart';

class ExpenseScreen extends StatefulWidget {
  final dynamic factory;

  const ExpenseScreen({super.key, required this.factory});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  String selectedFilter = "Today";

  final List<Map<String, dynamic>> expenses = [
    {
      "title": "Diesel",
      "category": "Fuel",
      "amount": 2500.0,
      "date": "10 Sep 2026",
      "icon": Icons.local_gas_station_rounded,
      "color": Colors.orange,
    },
    {
      "title": "Cement Purchase",
      "category": "Materials",
      "amount": 8500.0,
      "date": "10 Sep 2026",
      "icon": Icons.inventory_2_rounded,
      "color": Colors.blue,
    },
    {
      "title": "Worker Salary",
      "category": "Salary",
      "amount": 12000.0,
      "date": "09 Sep 2026",
      "icon": Icons.people_alt_rounded,
      "color": Colors.green,
    },
  ];

  double get totalExpense {
    return expenses.fold(
      0,
      (sum, expense) => sum + (expense["amount"] as double),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          "Expenses",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Expense",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),

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
                  "${expenses.length} Expenses",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (expenses.isEmpty)
              _buildEmptyState()
            else
              ...expenses.map((expense) => _buildExpenseCard(expense)),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SUMMARY CARD
  // ------------------------------------------------------------

  Widget _buildSummaryCard() {
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

              const Text(
                "Total Expenses",
                style: TextStyle(
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

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    final Color color = expense["color"] as Color;

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
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(expense["icon"] as IconData, color: color, size: 23),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense["title"],
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff111827),
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Text(
                      expense["category"],
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Container(
                      height: 3,
                      width: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      expense["date"],
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Text(
            "- ₹${(expense["amount"] as double).toStringAsFixed(2)}",
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xffDC2626),
            ),
          ),
        ],
      ),
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
            "Add your first factory expense",
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

  // ------------------------------------------------------------
  // ADD EXPENSE
  // ------------------------------------------------------------

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String category = "Other";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Add Expense",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Expense Name",
                      prefixIcon: const Icon(Icons.receipt_long_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      prefixIcon: const Icon(Icons.currency_rupee_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: InputDecoration(
                      labelText: "Category",
                      prefixIcon: const Icon(Icons.category_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "Fuel", child: Text("Fuel")),
                      DropdownMenuItem(
                        value: "Materials",
                        child: Text("Materials"),
                      ),
                      DropdownMenuItem(value: "Salary", child: Text("Salary")),
                      DropdownMenuItem(
                        value: "Electricity",
                        child: Text("Electricity"),
                      ),
                      DropdownMenuItem(
                        value: "Transport",
                        child: Text("Transport"),
                      ),
                      DropdownMenuItem(
                        value: "Maintenance",
                        child: Text("Maintenance"),
                      ),
                      DropdownMenuItem(value: "Other", child: Text("Other")),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        category = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty ||
                            amountController.text.trim().isEmpty) {
                          return;
                        }

                        final amount = double.tryParse(amountController.text);

                        if (amount == null || amount <= 0) {
                          return;
                        }

                        setState(() {
                          expenses.insert(0, {
                            "title": titleController.text.trim(),
                            "category": category,
                            "amount": amount,
                            "date": "10 Sep 2026",
                            "icon": Icons.receipt_long_rounded,
                            "color": Colors.red,
                          });
                        });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Save Expense",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

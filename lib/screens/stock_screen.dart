import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/stock_model.dart';
import 'package:bricks_application/repositories/stock_repository.dart';
import 'package:bricks_application/screens/stock_adjustment_history_screen.dart';
import 'package:flutter/material.dart';

class StockScreen extends StatelessWidget {
  final FactoryModel factory;

  StockScreen({super.key, required this.factory});

  final StockRepository stockRepository = StockRepository();

  // ============================================================
  // ADJUST STOCK DIALOG
  // ============================================================

  Future<void> _showAdjustStockDialog(
    BuildContext context,
    StockModel stock,
  ) async {
    final adjustmentController = TextEditingController();

    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Adjust ${stock.productName} Stock"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------
                    // CURRENT STOCK
                    // ------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Stock",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${stock.quantity.toStringAsFixed(0)} ${stock.unit}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ------------------------------------------------
                    // ADJUSTMENT QUANTITY
                    // ------------------------------------------------
                    TextField(
                      controller: adjustmentController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Adjustment Quantity",
                        hintText: "Example: -500 or 500",
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ------------------------------------------------
                    // REASON
                    // ------------------------------------------------
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Reason",
                        hintText: "Example: Damaged bricks",
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Use a negative value to reduce "
                      "stock or a positive value to "
                      "increase stock.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------
              // ACTION BUTTONS
              // ----------------------------------------------------
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final adjustment = double.tryParse(
                            adjustmentController.text.trim(),
                          );

                          final reason = reasonController.text.trim();

                          // ------------------------------------------
                          // VALIDATE QUANTITY
                          // ------------------------------------------

                          if (adjustment == null || adjustment == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Enter a valid "
                                  "adjustment quantity",
                                ),
                              ),
                            );
                            return;
                          }

                          // ------------------------------------------
                          // VALIDATE REASON
                          // ------------------------------------------

                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a reason"),
                              ),
                            );
                            return;
                          }

                          // ------------------------------------------
                          // CHECK NEGATIVE STOCK
                          // ------------------------------------------

                          final newStock = stock.quantity + adjustment;

                          if (newStock < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Stock cannot be negative. "
                                  "Available: "
                                  "${stock.quantity.toStringAsFixed(0)}",
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                          });

                          try {
                            // ----------------------------------------
                            // UPDATE STOCK + SAVE HISTORY
                            // ----------------------------------------

                            await stockRepository.adjustStock(
                              factoryId: stock.factoryId,
                              productId: stock.productId,
                              adjustment: adjustment,
                              reason: reason,
                            );

                            if (context.mounted) {
                              Navigator.pop(dialogContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Stock adjusted "
                                    "successfully",
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSaving = false;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to adjust "
                                    "stock: $e",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    adjustmentController.dispose();
    reasonController.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock"),
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,

        // --------------------------------------------------------
        // HISTORY BUTTON
        // --------------------------------------------------------
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Adjustment History",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StockAdjustmentHistoryScreen(factory: factory),
                ),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<StockModel>>(
        stream: stockRepository.getStock(factory.id),
        builder: (context, snapshot) {
          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error loading stock:\n"
                  "${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final stocks = snapshot.data ?? [];

          // ------------------------------------------------------
          // EMPTY
          // ------------------------------------------------------

          if (stocks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 15),
                  Text(
                    "No stock available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          // ------------------------------------------------------
          // TOTAL STOCK
          // ------------------------------------------------------

          final totalStock = stocks.fold<double>(
            0,
            (sum, stock) => sum + stock.quantity,
          );

          return Column(
            children: [
              // ==================================================
              // TOTAL STOCK CARD
              // ==================================================

              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            size: 32,
                            color: Colors.orange.shade700,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Available Stock",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                totalStock.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const Text(
                                "Bricks",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // PRODUCT STOCK LIST
              // ==================================================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: stocks.length,
                  itemBuilder: (context, index) {
                    final stock = stocks[index];

                    return _stockCard(context, stock);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // STOCK CARD
  // ============================================================

  Widget _stockCard(BuildContext context, StockModel stock) {
    final bool isOutOfStock = stock.quantity <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ----------------------------------------------------
            // PRODUCT HEADER
            // ----------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.view_module_rounded,
                    color: Colors.orange.shade700,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.productName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Show the brick size clearly.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          stock.productSize.isEmpty
                              ? 'Size not set'
                              : stock.productSize,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stock.quantity.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stock.unit,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),

            const Divider(),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // AVAILABLE STOCK
            // ----------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Available Stock",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),

                Text(
                  stock.quantity.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ----------------------------------------------------
            // PRODUCED
            // ----------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Produced"),
                Text(stock.producedQuantity.toStringAsFixed(0)),
              ],
            ),

            const SizedBox(height: 6),

            // ----------------------------------------------------
            // SOLD
            // ----------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sold"),
                Text(stock.soldQuantity.toStringAsFixed(0)),
              ],
            ),
            const SizedBox(height: 6),

            // STOCK ADJUSTMENT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune, size: 18, color: Colors.deepOrange),
                    SizedBox(width: 6),
                    Text("Stock Adjustment"),
                  ],
                ),
                Text(
                  stock.adjustmentQuantity.toStringAsFixed(0),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: stock.adjustmentQuantity < 0
                        ? Colors.red
                        : stock.adjustmentQuantity > 0
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ----------------------------------------------------
            // STATUS
            // ----------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isOutOfStock ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOutOfStock ? "Out of Stock" : "In Stock",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isOutOfStock ? Colors.red : Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ----------------------------------------------------
            // ADJUST STOCK BUTTON
            // ----------------------------------------------------
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showAdjustStockDialog(context, stock);
                },
                icon: const Icon(Icons.edit_note),
                label: const Text("Adjust Stock"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

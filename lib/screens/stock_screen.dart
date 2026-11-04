import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/stock_model.dart';
import 'package:bricks_application/repositories/stock_repository.dart';
import 'package:bricks_application/screens/stock_adjustment_history_screen.dart';
import 'package:flutter/material.dart';

class StockScreen extends StatelessWidget {
  final FactoryModel factory;

  StockScreen({super.key, required this.factory});

  final StockRepository stockRepository = StockRepository();

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color secondaryTextColor = Color(0xFF7B8497);

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
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Adjust Stock',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  stock.productName,
                                  style: const TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CURRENT STOCK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${stock.quantity.toStringAsFixed(0)} ${stock.unit}',
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Adjustment Quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: adjustmentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Example: -500 or 500',
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E9F2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 17),

                      const Text(
                        'Reason',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Example: Damaged bricks',
                          prefixIcon: const Icon(Icons.notes_rounded),
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E9F2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.orange,
                              size: 19,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Use a negative value to reduce stock or a positive value to increase stock.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9A5B16),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      final adjustment = double.tryParse(
                                        adjustmentController.text.trim(),
                                      );

                                      final reason = reasonController.text
                                          .trim();

                                      if (adjustment == null ||
                                          adjustment == 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Enter a valid adjustment quantity',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (reason.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please enter a reason',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final newStock =
                                          stock.quantity + adjustment;

                                      if (newStock < 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Stock cannot be negative. Available: ${stock.quantity.toStringAsFixed(0)}',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setDialogState(() {
                                        isSaving = true;
                                      });

                                      try {
                                        await stockRepository.adjustStock(
                                          factoryId: stock.factoryId,
                                          productId: stock.productId,
                                          adjustment: adjustment,
                                          reason: reason,
                                        );

                                        if (context.mounted) {
                                          Navigator.pop(dialogContext);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Stock adjusted successfully',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setDialogState(() {
                                          isSaving = false;
                                        });

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to adjust stock: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.white,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Management',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Monitor your product inventory',
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Adjustment History',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        StockAdjustmentHistoryScreen(factory: factory),
                  ),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: primaryColor,
              ),
              icon: const Icon(Icons.history_rounded),
            ),
          ),
        ],
      ),

      body: StreamBuilder<List<StockModel>>(
        stream: stockRepository.getStock(factory.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading stock:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final stocks = snapshot.data ?? [];

          if (stocks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 105,
                      width: 105,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No stock available',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Your product stock will appear here once available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            );
          }

          final totalStock = stocks.fold<double>(
            0,
            (sum, stock) => sum + stock.quantity,
          );

          return Column(
            children: [
              // TOTAL STOCK SUMMARY

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.20),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 58,
                        width: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL AVAILABLE STOCK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              totalStock.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 32,
                                height: 1,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bricks',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.stacked_bar_chart_rounded,
                        color: Colors.white70,
                        size: 35,
                      ),
                    ],
                  ),
                ),
              ),

              // LIST HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Product Inventory',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE6EAF1)),
                      ),
                      child: Text(
                        '${stocks.length} Products',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PRODUCT STOCK LIST
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

    final Color statusColor = isOutOfStock
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);

    final Color statusBackground = isOutOfStock
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF0FDF4);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEDF0F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PRODUCT HEADER

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.view_module_rounded,
                    color: Color(0xFFEA8A19),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          stock.productSize.isEmpty
                              ? 'Size not set'
                              : stock.productSize,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
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
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      stock.unit,
                      style: const TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 17),

            // AVAILABLE STOCK
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.warehouse_outlined,
                        size: 19,
                        color: primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Available Stock',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${stock.quantity.toStringAsFixed(0)} ${stock.unit}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PRODUCTION / SALES / ADJUSTMENT
            Row(
              children: [
                Expanded(
                  child: _infoItem(
                    icon: Icons.precision_manufacturing_outlined,
                    label: 'Produced',
                    value: stock.producedQuantity.toStringAsFixed(0),
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoItem(
                    icon: Icons.shopping_cart_outlined,
                    label: 'Sold',
                    value: stock.soldQuantity.toStringAsFixed(0),
                    color: const Color(0xFFEA8A19),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoItem(
                    icon: Icons.tune_rounded,
                    label: 'Adjusted',
                    value: stock.adjustmentQuantity.toStringAsFixed(0),
                    color: stock.adjustmentQuantity < 0
                        ? Colors.red
                        : stock.adjustmentQuantity > 0
                        ? Colors.green
                        : secondaryTextColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // STATUS
            Row(
              children: [
                Container(
                  height: 9,
                  width: 9,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  isOutOfStock ? 'Out of Stock' : 'In Stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    _showAdjustStockDialog(context, stock);
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Adjust Stock'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STOCK INFORMATION ITEM
  // ============================================================

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F2F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 9),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: secondaryTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:bricks_application/models/factory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockAdjustmentHistoryScreen extends StatelessWidget {
  final FactoryModel factory;

  const StockAdjustmentHistoryScreen({super.key, required this.factory});

  static const Color primaryColor = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF5F7FB);
  static const Color textColor = Color(0xFF172033);
  static const Color secondaryTextColor = Color(0xFF7B8497);

  // ============================================================
  // FIRESTORE COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>> get _historyCollection {
    return FirebaseFirestore.instance
        .collection('factories')
        .doc(factory.id)
        .collection('stockAdjustments');
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return '-';
    }

    final date = timestamp.toDate();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
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
              'Adjustment History',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Track all manual stock changes',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _historyCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // LOADING

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // ERROR

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading adjustment history:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          // EMPTY

          if (documents.isEmpty) {
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
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No adjustment history',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manual stock adjustments will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            );
          }

          // HISTORY LIST

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data();

              final adjustment = (data['adjustment'] as num?)?.toDouble() ?? 0;

              final previousStock =
                  (data['previousStock'] as num?)?.toDouble() ?? 0;

              final newStock = (data['newStock'] as num?)?.toDouble() ?? 0;

              final productName = data['productName'] ?? 'Unknown Product';

              final unit = data['unit'] ?? 'pcs';

              final reason = data['reason'] ?? '-';

              final createdAt = data['createdAt'] as Timestamp?;

              final bool isIncrease = adjustment > 0;

              final Color adjustmentColor = isIncrease
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626);

              final Color adjustmentBackground = isIncrease
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFFEF2F2);

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
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
                  padding: const EdgeInsets.all(17),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER

                      Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: adjustmentBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isIncrease
                                  ? Icons.add_rounded
                                  : Icons.remove_rounded,
                              color: adjustmentColor,
                              size: 27,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: secondaryTextColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        _formatDate(createdAt),
                                        style: const TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: adjustmentBackground,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Text(
                              '${isIncrease ? '+' : ''}${adjustment.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: adjustmentColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // STOCK COMPARISON
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _stockValue(
                                label: 'Previous Stock',
                                value:
                                    '${previousStock.toStringAsFixed(0)} $unit',
                              ),
                            ),

                            Container(
                              height: 42,
                              width: 1,
                              color: const Color(0xFFE5E9F0),
                            ),

                            Expanded(
                              child: _stockValue(
                                label: 'New Stock',
                                value: '${newStock.toStringAsFixed(0)} $unit',
                                highlight: true,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // REASON
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.notes_rounded,
                              size: 18,
                              color: Color(0xFFEA8A19),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reason',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  reason,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  // ============================================================
  // STOCK VALUE WIDGET
  // ============================================================

  Widget _stockValue({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: secondaryTextColor),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: highlight ? primaryColor : textColor,
            ),
          ),
        ],
      ),
    );
  }
}

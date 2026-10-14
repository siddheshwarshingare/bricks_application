import 'package:bricks_application/models/factory_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockAdjustmentHistoryScreen extends StatelessWidget {
  final FactoryModel factory;

  const StockAdjustmentHistoryScreen({super.key, required this.factory});

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

    return '$day/$month/$year  '
        '$hour:$minute';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adjustment History"),
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _historyCollection
            .orderBy('createdAt', descending: true)
            .snapshots(),

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
                  "Error loading adjustment history:\n"
                  "${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          // ------------------------------------------------------
          // EMPTY
          // ------------------------------------------------------

          if (documents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 70, color: Colors.grey),

                  SizedBox(height: 15),

                  Text(
                    "No adjustment history",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Manual stock adjustments "
                    "will appear here.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ------------------------------------------------------
          // HISTORY LIST
          // ------------------------------------------------------

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------------------------
                      // HEADER
                      // ------------------------------------------

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isIncrease
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isIncrease ? Icons.add : Icons.remove,
                              color: isIncrease ? Colors.green : Colors.red,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  _formatDate(createdAt),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            '${isIncrease ? '+' : ''}'
                            '${adjustment.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isIncrease ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      const Divider(),

                      const SizedBox(height: 10),

                      // ------------------------------------------
                      // PREVIOUS STOCK
                      // ------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Previous Stock"),
                          Text(
                            '${previousStock.toStringAsFixed(0)} '
                            '$unit',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // ------------------------------------------
                      // NEW STOCK
                      // ------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("New Stock"),
                          Text(
                            '${newStock.toStringAsFixed(0)} '
                            '$unit',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ------------------------------------------
                      // REASON
                      // ------------------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Reason",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              reason,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
}

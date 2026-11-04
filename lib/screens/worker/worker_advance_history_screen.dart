import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkerAdvanceHistoryScreen extends StatelessWidget {
  final String factoryId;
  final String workerId;
  final String workerName;

  const WorkerAdvanceHistoryScreen({
    super.key,
    required this.factoryId,
    required this.workerId,
    required this.workerName,
  });

  static const Color primaryColor = Color(0xff2563EB);

  String formatAmount(dynamic value) {
    if (value is num) {
      return '₹${value.toStringAsFixed(0)}';
    }

    return '₹${double.tryParse(value?.toString() ?? '')?.toStringAsFixed(0) ?? '0'}';
  }

  DateTime? getPaymentDate(Map<String, dynamic> data) {
    // Replace or add keys here if your Firestore schema differs.
    for (final key in ['createdAt', 'paymentDate', 'date', 'timestamp']) {
      final value = data[key];

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is DateTime) {
        return value;
      }
    }

    return null;
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';

    final d = date.toLocal();
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';

    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}  $hour:$minute $period';
  }

  double getAmount(Map<String, dynamic> data) {
    final amount = data['amount'];

    if (amount is num) return amount.toDouble();
    return double.tryParse(amount?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final paymentsQuery = FirebaseFirestore.instance
        .collection('factories')
        .doc(factoryId)
        .collection('worker_payments')
        .where('workerId', isEqualTo: workerId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Advance History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: paymentsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load advance history:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final payments = snapshot.data?.docs.toList() ?? [];

          payments.sort((a, b) {
            final dateA = getPaymentDate(a.data());
            final dateB = getPaymentDate(b.data());

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA);
          });

          double totalAdvance = 0;

          for (final payment in payments) {
            totalAdvance += getAmount(payment.data());
          }

          return Column(
            children: [
              // Worker and total summary
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xffEFF6FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff111827),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Total Advance Given',
                      style: TextStyle(color: Color(0xff1D4ED8), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatAmount(totalAdvance),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payments.length} transaction(s)',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: payments.isEmpty
                    ? const Center(
                        child: Text('No advance transactions found.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final doc = payments[index];
                          final data = doc.data();

                          final amount = getAmount(data);
                          final date = getPaymentDate(data);

                          final method =
                              data['paymentMethod'] ??
                              data['paymentMode'] ??
                              data['mode'] ??
                              data['paymentType'] ??
                              'Not specified';

                          final remarks =
                              data['remarks'] ??
                              data['note'] ??
                              data['description'] ??
                              '';

                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xffE5E7EB)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Color(0xffDCFCE7),
                                        child: Icon(
                                          Icons.payments,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Advance #${payments.length - index}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formatDate(date),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          formatAmount(amount),
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 28),
                                  _detailRow(
                                    Icons.account_balance,
                                    'Payment method',
                                    method.toString(),
                                  ),
                                  if (remarks.toString().trim().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _detailRow(
                                      Icons.notes,
                                      'Remarks',
                                      remarks.toString(),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    'Transaction ID: ${doc.id}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

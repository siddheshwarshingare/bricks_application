import 'package:bricks_application/screens/worker/worker_advance_history_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/screens/worker/pay_worker_screen.dart';
import 'package:bricks_application/services/worker_report_service.dart';
import 'package:flutter/material.dart';

class WorkerAccountScreen extends StatelessWidget {
  final FactoryModel factory;
  final WorkerModel worker;

  const WorkerAccountScreen({
    super.key,
    required this.factory,
    required this.worker,
  });

  Widget _buildValue(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget infoCardt(
    String title,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(title, textAlign: TextAlign.center),
              if (onTap != null)
                const Text(
                  'Tap to view history',
                  style: TextStyle(fontSize: 10, color: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productionRepository = ProductionRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          worker.name,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff2563EB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker details
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      child: Text(
                        worker.name.isNotEmpty
                            ? worker.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.name,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('📞 ${worker.mobile}'),
                          Text('🛠 ${worker.workType}'),
                          Text('💰 Rate: ₹${worker.ratePer1000}/1000'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Production records
            StreamBuilder<List<ProductionModel>>(
              stream: productionRepository.getWorkerProductions(
                factory.id,
                worker.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error loading productions: ${snapshot.error}');
                }

                final productions = snapshot.data ?? [];

                double totalBricks = 0;
                double totalEarned = 0;
                double totalSalaryPaid = 0;
                double totalReturned = 0;

                for (final production in productions) {
                  totalBricks += production.bricksProduced;
                  totalEarned += production.salaryEarned;
                  totalSalaryPaid += production.salaryPaid;
                  totalReturned += production.cashReturned;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary and advances
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('factories')
                          .doc(factory.id)
                          .collection('worker_payments')
                          .where('workerId', isEqualTo: worker.id)
                          .snapshots(),
                      builder: (context, paymentSnapshot) {
                        if (paymentSnapshot.hasError) {
                          return Text(
                            'Error loading worker payments: '
                            '${paymentSnapshot.error}',
                          );
                        }

                        if (paymentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        double totalAdvanceGiven = 0;

                        for (final doc in paymentSnapshot.data?.docs ?? []) {
                          final amount = doc.data()['amount'];

                          if (amount is num) {
                            totalAdvanceGiven += amount.toDouble();
                          } else if (amount is String) {
                            totalAdvanceGiven += double.tryParse(amount) ?? 0;
                          }
                        }

                        // Required calculation:
                        // Remaining Advance = Advance Given - Returned
                        final double remainingAdvance =
                            totalAdvanceGiven - totalReturned;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Worker Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 1.2,
                              children: [
                                infoCard(
                                  'Total Bricks',
                                  totalBricks.toStringAsFixed(0),
                                  Icons.grid_view,
                                  Colors.orange,
                                ),
                                infoCard(
                                  'Total Earned',
                                  '₹${totalEarned.toStringAsFixed(0)}',
                                  Icons.currency_rupee,
                                  Colors.green,
                                ),
                                infoCard(
                                  'Salary Paid',
                                  '₹${totalSalaryPaid.toStringAsFixed(0)}',
                                  Icons.payments,
                                  Colors.blue,
                                ),
                                infoCardt(
                                  'Total Advance Given',
                                  '₹${totalAdvanceGiven.toStringAsFixed(0)}',
                                  Icons.account_balance_wallet,
                                  Colors.blue,
                                  onTap: () {
                                    Navigator.push(
                                       context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            WorkerAdvanceHistoryScreen(
                                              factoryId: factory.id,
                                              workerId: worker.id,
                                              workerName: worker.name,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                // infoCard(
                                //   'Total Advance Given',
                                //   '₹${totalAdvanceGiven.toStringAsFixed(0)}',
                                //   Icons.account_balance_wallet,
                                //   Colors.blue,
                                // ),
                                infoCard(
                                  'Total Returned',
                                  '₹${totalReturned.toStringAsFixed(0)}',
                                  Icons.reply,
                                  Colors.deepOrange,
                                ),
                                infoCard(
                                  'Remaining Advance',
                                  '₹${remainingAdvance.toStringAsFixed(0)}',
                                  Icons.account_balance_wallet,
                                  remainingAdvance < 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Production history
                    const Text(
                      'Production History',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (productions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No production records found.'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productions.length,
                        itemBuilder: (context, index) {
                          final production = productions[index];
                          final date = production.productionDate.toDate();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xffE5E7EB),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${production.bricksProduced} Bricks',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildValue(
                                          'Salary',
                                          '₹${production.salaryEarned.toStringAsFixed(0)}',
                                          Colors.green,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildValue(
                                          'Paid',
                                          '₹${production.salaryPaid.toStringAsFixed(0)}',
                                          Colors.blue,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildValue(
                                          'Returned',
                                          '₹${production.cashReturned.toStringAsFixed(0)}',
                                          Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${date.day}/${date.month}/${date.year}',
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    // Download report
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            onPressed: () async {
                              await WorkerReportService.downloadWorkerReport(
                                factory: factory,
                                worker: worker,
                                productions: productions,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            onPressed: () async {
                              await WorkerReportService.shareWorkerReport(
                                factory: factory,
                                worker: worker,
                                productions: productions,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Pay salary
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payments),
                label: const Text('Pay Salary'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PayWorkerScreen(worker: worker),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/screens/worker/pay_worker_screen.dart';
import 'package:flutter/material.dart';

class WorkerAccountScreen extends StatelessWidget {
  final FactoryModel factory;
  final WorkerModel worker;

  const WorkerAccountScreen({
    super.key,
    required this.factory,
    required this.worker,
  });

  @override
  Widget build(BuildContext context) {
    final ProductionRepository productionRepository = ProductionRepository();
    return Scaffold(
      appBar: AppBar(title: Text(worker.name)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Worker Card
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
                        worker.name[0].toUpperCase(),
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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text("📞 ${worker.mobile}"),

                          Text("🛠 ${worker.workType}"),

                          Text("💰 Rate : ₹${worker.ratePer1000}/1000"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            StreamBuilder<List<ProductionModel>>(
              stream: productionRepository.getWorkerProductions(
                factory.id,
                worker.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final productions = snapshot.data ?? [];

                double totalBricks = 0;
                double totalEarned = 0;
                double totalPaid = 0;

                for (final p in productions) {
                  totalBricks += p.bricksProduced;
                  totalEarned += p.salaryEarned;
                  totalPaid += p.salaryPaid;
                }

                final pending = totalEarned - totalPaid;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Worker Summary",
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
                          "Total Bricks",
                          totalBricks.toStringAsFixed(0),
                          Icons.grid_view,
                          Colors.orange,
                        ),

                        infoCard(
                          "Total Earned",
                          "₹${totalEarned.toStringAsFixed(0)}",
                          Icons.currency_rupee,
                          Colors.green,
                        ),

                        infoCard(
                          "Salary Paid",
                          "₹${totalPaid.toStringAsFixed(0)}",
                          Icons.payments,
                          Colors.blue,
                        ),

                        infoCard(
                          "Pending",
                          "₹${pending.toStringAsFixed(0)}",
                          Icons.account_balance_wallet,
                          Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Production History",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productions.length,
                      itemBuilder: (context, index) {
                        final production = productions[index];

                        return Card(
                          child: ListTile(
                            title: Text(
                              "${production.bricksProduced.toString()} Bricks",
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Earned : ₹${production.salaryEarned}"),
                                Text("Paid : ₹${production.salaryPaid}"),
                                Text("Remarks : ${production.remarks}"),
                              ],
                            ),
                            trailing: Text(
                              "${production.productionDate.toDate().day}/"
                              "${production.productionDate.toDate().month}/"
                              "${production.productionDate.toDate().year}",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 15),

            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.payments),
              label: const Text("Pay Salary"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PayWorkerScreen(worker: worker),
                  ),
                );
              },
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  "Production history will come here",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
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
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(title),
        ],
      ),
    );
  }
}

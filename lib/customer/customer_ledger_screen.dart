import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/ledger_model.dart';
import 'package:bricks_application/repositories/ledger_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerLedgerScreen extends StatelessWidget {
  CustomerLedgerScreen({super.key, required this.customer});

  final CustomerModel customer;

  final LedgerRepository repository = LedgerRepository();

  Color getColor(String type) {
    return type == "Sale" ? Colors.red : Colors.green;
  }

  IconData getIcon(String type) {
    return type == "Sale" ? Icons.shopping_cart : Icons.payments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Ledger"), centerTitle: true),
      body: StreamBuilder<List<LedgerModel>>(
        stream: repository.getCustomerLedger(
          customer.factoryId,
          customer.id,
          customer.openingBalance,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final ledger = snapshot.data ?? [];

          return Column(
            children: [
              /// Customer Card
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.person),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                customer.mobile,
                                style: const TextStyle(color: Colors.white),
                              ),

                              Text(
                                customer.village,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white, height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pending Balance",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "₹ ${customer.pendingBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ledger.isEmpty
                    ? const Center(
                        child: Text(
                          "No Ledger Available",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: ledger.length,
                        itemBuilder: (context, index) {
                          final item = ledger[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: getColor(
                                      item.type,
                                    ).withValues(alpha: .15),
                                    child: Icon(
                                      getIcon(item.type),
                                      color: getColor(item.type),
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.type,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          DateFormat(
                                            "dd MMM yyyy",
                                          ).format(item.date),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          item.description,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (item.debit > 0)
                                        Text(
                                          "+ ₹${item.debit.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                      if (item.credit > 0)
                                        Text(
                                          "- ₹${item.credit.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                      const SizedBox(height: 8),

                                      Text(
                                        "Balance",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),

                                      Text(
                                        "₹${item.balance.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
}

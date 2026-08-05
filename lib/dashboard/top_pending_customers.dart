import 'package:bricks_application/customer/customer_dashboard_screen.dart';
import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:flutter/material.dart';

class TopPendingCustomers extends StatelessWidget {
  final FactoryModel factory;

  const TopPendingCustomers({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    final repository = CustomerRepository();

    return StreamBuilder(
      stream: repository.topPendingCustomers(factory.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final customers = snapshot.data!.docs
            .map((e) => CustomerModel.fromFirestore(e))
            .toList();

        if (customers.isEmpty) {
          return const Text("No Pending Customers");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top Pending Customers",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            ...customers.map(
              (customer) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(customer.name),
                  subtitle: Text(customer.mobile),
                  trailing: Text(
                    "₹${customer.pendingBalance.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerDashboardScreen(
                          factory: factory,
                          customer: customer,
                        ),
                      ),
                    );
                    // Open Customer Details
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

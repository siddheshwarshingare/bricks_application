import 'package:bricks_application/customer/add_customer_screen.dart';
import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/screens/sale/add_sale_screen.dart';
import 'package:flutter/material.dart';

class SelectCustomerForSaleScreen extends StatefulWidget {
  final FactoryModel factory;

  const SelectCustomerForSaleScreen({super.key, required this.factory});

  @override
  State<SelectCustomerForSaleScreen> createState() =>
      _SelectCustomerForSaleScreenState();
}

class _SelectCustomerForSaleScreenState
    extends State<SelectCustomerForSaleScreen> {
  final CustomerRepository repository = CustomerRepository();

  final TextEditingController searchController = TextEditingController();

  String search = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Customer")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCustomerScreen(factory: widget.factory),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text("New Customer"),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by Name or Mobile",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<CustomerModel>>(
              stream: repository.getCustomers(widget.factory.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final customers = snapshot.data ?? [];

                final filtered = customers.where((customer) {
                  return customer.name.toLowerCase().contains(search) ||
                      customer.mobile.contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Customers Found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final customer = filtered[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),

                        title: Text(customer.name),

                        subtitle: Text(customer.mobile),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddSaleScreen(
                                factory: widget.factory,
                                customer: customer,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

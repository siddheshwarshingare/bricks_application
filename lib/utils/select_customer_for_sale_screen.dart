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

  void openSale(CustomerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddSaleScreen(factory: widget.factory, customer: customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text(
          "New Sale",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xff2563EB),
      ),

      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search customer...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Add customer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // We will connect your existing AddCustomerScreen here
                  // in the next step.
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Add New Customer"),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Customer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 8),

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
                      customer.mobile.toLowerCase().contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      "No customers found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final customer = filtered[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),

                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xffEFF6FF),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xff2563EB),
                          ),
                        ),

                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: Text(
                          "${customer.mobile} • ${customer.village}",
                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),

                        onTap: () {
                          openSale(customer);
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

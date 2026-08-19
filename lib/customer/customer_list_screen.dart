import 'package:bricks_application/customer/add_customer_screen.dart';
import 'package:bricks_application/customer/customer_dashboard_screen.dart';
import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/services/invoice_service.dart';
import 'package:flutter/material.dart';

class CustomerListScreen extends StatefulWidget {
  final FactoryModel factory;

  const CustomerListScreen({super.key, required this.factory});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerRepository repository = CustomerRepository();

  final TextEditingController searchController = TextEditingController();
  final double totalQuantity = 0;
  String search = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<bool?> deleteDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Customer"),
        content: const Text("Are you sure you want to delete this customer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.factory.name} Customers",
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,

        backgroundColor: const Color(0xff2563EB),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff2563EB),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCustomerScreen(factory: widget.factory),
            ),
          );
        },
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Customer",
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

                final filteredCustomers = customers.where((customer) {
                  return customer.name.toLowerCase().contains(search) ||
                      customer.mobile.contains(search);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Customers Found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];

                    return Dismissible(
                      key: Key(customer.id),
                      direction: DismissDirection.endToStart,

                      confirmDismiss: (_) async {
                        return await deleteDialog();
                      },

                      onDismissed: (_) async {
                        await repository.deleteCustomer(
                          widget.factory.id,
                          customer.id,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${customer.name} deleted")),
                        );
                      },

                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      child: Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),

                          title: Text(
                            customer.name,
                            style: const TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff111827),
                            ),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text("📞 ${customer.mobile}"),

                              Text(
                                "🧱 Purchased : ${customer.totalQuantity.toStringAsFixed(0)} Bricks",
                              ),

                              Text(
                                "💰 Purchase : ₹${customer.totalPurchase.toStringAsFixed(0)}",
                              ),

                              Text(
                                "💵 Paid : ₹${customer.totalPaid.toStringAsFixed(0)}",
                              ),

                              //  Text("📍 ${customer.address}"),
                              Text("Village : ${customer.village}"),

                              Text(
                                "Pending : ₹${customer.pendingBalance.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == "generate") {
                                await InvoiceService.downloadCustomerInvoice(
                                  factory: widget.factory,
                                  customer: customer,
                                );
                              }

                              if (value == "send") {
                                await InvoiceService.shareCustomerInvoice(
                                  factory: widget.factory,
                                  customer: customer,
                                );
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: "generate",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Generate Invoice"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: "send",
                                child: Row(
                                  children: [
                                    Icon(Icons.send, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Text("Send Invoice"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // trailing: Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     IconButton(
                          //       icon: const Icon(
                          //         Icons.edit,
                          //         color: Colors.blue,
                          //       ),
                          //       onPressed: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (_) => AddCustomerScreen(
                          //               factory: widget.factory,
                          //               customer: customer,
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //     ),

                          //     const Icon(Icons.arrow_forward_ios, size: 18),
                          //   ],
                          // ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerDashboardScreen(
                                  factory: widget.factory,
                                  customer: customer,
                                ),
                              ),
                            );
                          },
                        ),
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

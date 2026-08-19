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

  // Colors from your reference design
  static const Color primaryBlue = Color(0xff2563EB);
  static const Color lightBlue = Color(0xffEFF6FF);
  static const Color backgroundColor = Color(0xffF5F7FB);
  static const Color darkText = Color(0xff111827);
  static const Color greyText = Color(0xff6B7280);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Select Customer",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCustomerScreen(factory: widget.factory),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text(
          "New Customer",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          // Search Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search customer...",
                  hintStyle: const TextStyle(color: greyText),
                  prefixIcon: const Icon(Icons.search, color: primaryBlue),
                  suffixIcon: search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();

                            setState(() {
                              search = "";
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    search = value.toLowerCase().trim();
                  });
                },
              ),
            ),
          ),

          // Customer title
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
            child: Row(
              children: [
                const Text(
                  "Customers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),

                const Spacer(),

                StreamBuilder<List<CustomerModel>>(
                  stream: repository.getCustomers(widget.factory.id),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "$count Customers",
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Customer List
          Expanded(
            child: StreamBuilder<List<CustomerModel>>(
              stream: repository.getCustomers(widget.factory.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final customers = snapshot.data ?? [];

                final filtered = customers.where((customer) {
                  return customer.name.toLowerCase().contains(search) ||
                      customer.mobile.contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: lightBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_search,
                            size: 45,
                            color: primaryBlue,
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          "No Customers Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          search.isEmpty
                              ? "Add your first customer"
                              : "Try another name or mobile number",
                          style: const TextStyle(color: greyText),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final customer = filtered[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Customer Icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: lightBlue,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: primaryBlue,
                                  size: 27,
                                ),
                              ),

                              const SizedBox(width: 14),

                              // Customer Information
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: darkText,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 15,
                                          color: greyText,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          customer.mobile,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: greyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Arrow
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
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

import 'package:bricks_application/customer/customer_list_screen.dart';
import 'package:bricks_application/dashboard/quick_action_card.dart';
import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/dashboard_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/payment/payment_history_screen.dart';
import 'package:bricks_application/payment/receive_payment_screen.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/repositories/dashboard_repository.dart';
import 'package:bricks_application/screens/materials/material_list_screen.dart';
import 'package:bricks_application/screens/production/production_list_screen.dart';
import 'package:bricks_application/screens/reports/reports_screen.dart';
import 'package:bricks_application/screens/sale/sale_list_screen.dart';
import 'package:bricks_application/screens/sale/select_customer_for_sale_screen.dart';
import 'package:bricks_application/screens/worker/worker_list_screen.dart';
import 'package:bricks_application/utils/customer_selector.dart';
import 'package:flutter/material.dart';

class FactoryDashboardScreen extends StatefulWidget {
  final FactoryModel factory;

  FactoryDashboardScreen({super.key, required this.factory});

  @override
  State<FactoryDashboardScreen> createState() => _FactoryDashboardScreenState();
}

class _FactoryDashboardScreenState extends State<FactoryDashboardScreen> {
  final DashboardRepository dashboardRepository = DashboardRepository();
  DashboardFilter selectedFilter = DashboardFilter.today;
  final CustomerRepository customerRepository = CustomerRepository();
  Future<void> loadCustomers() async {
    customerRepository.getCustomers(widget.factory.id).first.then((value) {
      if (mounted) {
        setState(() {
          customers = value;
        });
      }
    });
  }

  List<CustomerModel> customers = [];
  Widget menuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(.20),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.factory.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: Colors.grey),

            const SizedBox(width: 5),

            Expanded(
              child: Text(
                widget.factory.location,
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const Icon(Icons.person, size: 18, color: Colors.grey),

            const SizedBox(width: 5),

            Text(
              widget.factory.owner,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> selectCustomer() async {
    if (customers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No Customers Found")));
      return;
    }

    final CustomerModel? customer = await showDialog<CustomerModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Customer"),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final item = customers[index];

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(item.name),
                  subtitle: Text(item.mobile),
                  onTap: () {
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (customer != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SaleListScreen(factory: widget.factory, customer: customer),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: Text(
          widget.factory.name,
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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildHeader(),
              const SizedBox(height: 15),

              buildDashboardFilter(),

              const SizedBox(height: 20),

              StreamBuilder<DashboardModel>(
                stream: dashboardRepository.getDashboardData(
                  widget.factory.id,
                  selectedFilter,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      buildDashboardCard(
                        "${data.production.toStringAsFixed(0)} Bricks",
                        "Production(This Week)",
                        Icons.factory,
                        Colors.orange,
                      ),
                      buildDashboardCard(
                        "${data.salesQuantity.toStringAsFixed(0)}",
                        "Bricks Sold",
                        Icons.shopping_cart,
                        Colors.green,
                      ),
                      buildDashboardCard(
                        "₹${data.sales.toStringAsFixed(0)}",
                        "Sales",
                        Icons.currency_rupee,
                        Colors.green,
                      ),

                      buildDashboardCard(
                        "₹${data.collection.toStringAsFixed(0)}",
                        "Collection",
                        Icons.payments,
                        Colors.blue,
                      ),

                      buildDashboardCard(
                        "₹${data.pending.toStringAsFixed(0)}",
                        "Pending",
                        Icons.account_balance_wallet,
                        Colors.red,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 11),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [
                  QuickActionCard(
                    title: "Production",
                    icon: Icons.factory,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductionListScreen(factory: widget.factory),
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) =>
                      //         AddProductionScreen(factory: widget.factory),
                      //   ),
                      // );
                    },
                  ),
                  // QuickActionCard(
                  //   title: "New Sale",
                  //   icon: Icons.shopping_cart,
                  //   color: const Color(0xff2563EB),
                  //   onTap: () {
                  //     selectCustomer();
                  //   },
                  // ),
                  QuickActionCard(
                    title: "New Sale",
                    icon: Icons.shopping_cart,
                    color: const Color(0xff2563EB),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectCustomerForSaleScreen(
                            factory: widget.factory,
                          ),
                        ),
                      );
                    },
                  ),
                  menuCard(
                    context,
                    "Receive Payment",
                    Icons.payments,
                    Colors.blue,
                    () async {
                      final customer = await CustomerSelector.show(
                        context,
                        customers,
                      );

                      if (customer != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReceivePaymentScreen(customer: customer),
                          ),
                        );
                      }

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) =>
                      //         ReceivePaymentScreen(customer: customer),
                      //   ),
                      // );
                    },
                  ),
                  menuCard(
                    context,
                    "Payment History",
                    Icons.history,
                    Colors.green,
                    () async {
                      final customer = await CustomerSelector.show(
                        context,
                        customers,
                      );
                      if (customer != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentHistoryScreen(customer: customer),
                          ),
                        );
                      }
                    },
                  ),
                  menuCard(
                    context,
                    "Sales History",
                    Icons.history,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerListScreen(factory: widget.factory),
                        ),
                      );
                    },
                  ),
                  // menuCard(
                  //   context,
                  //   "Sales History",
                  //   Icons.history,
                  //   Colors.green,
                  //   () async {
                  //     final customer = await CustomerSelector.show(
                  //       context,
                  //       customers,
                  //     );
                  //     if (customer != null) {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (_) => SaleListScreen(
                  //             factory: widget.factory,
                  //             customer: customer,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),
                  //                   QuickActionCard(
                  //   title: "Sales History",
                  //   icon: Icons.receipt_long,
                  //   color: Colors.indigo,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => SaleListScreen(
                  //           factory: widget.factory, customer:customer ,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  //                   QuickActionCard(
                  //                     title: "New Sale",
                  //                     icon: Icons.factory,
                  //                     color: Colors.orange,
                  //                     onTap: () {
                  //                        Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                       builder: (_) =>
                  //                           SaleListScreen(factory:widget.factory, customer:widget.customer),
                  //                     ),
                  //                   );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => SelectCustomerForSaleScreen(
                  //       factory: widget.factory,
                  //     ),
                  //   ),
                  // );
                  //   },
                  //),
                  // QuickActionCard(
                  //   title: "Production",
                  //   icon: Icons.factory,
                  //   color: Colors.orange,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) =>
                  //             AddProductionScreen(factory: widget.factory),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // QuickActionCard(
                  //   title: "Production",
                  //   icon: Icons.factory,
                  //   color: Colors.orange,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) =>
                  //             AddProductionScreen(factory: widget.factory),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // QuickActionCard(
                  //   title: "Production",
                  //   icon: Icons.factory,
                  //   color: Colors.orange,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) =>
                  //             AddProductionScreen(factory: widget.factory),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // Cards here
                ],
              ),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: .95,
                children: [
                  menuCard(
                    context,
                    "Production",
                    Icons.factory,
                    const Color.fromARGB(255, 39, 30, 17),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductionListScreen(factory: widget.factory),
                        ),
                      );
                    },
                  ),

                  menuCard(context, "Workers", Icons.people, Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WorkerListScreen(factory: widget.factory),
                      ),
                    );
                  }),

                  menuCard(
                    context,
                    "Materials",
                    Icons.inventory,
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MaterialListScreen(factory: widget.factory),
                        ),
                      );
                    },
                  ),
                  menuCard(context, "Customers", Icons.people, Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CustomerListScreen(factory: widget.factory),
                      ),
                    );
                  }),
                  menuCard(
                    context,
                    "Reports",
                    Icons.bar_chart,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ReportsScreen(factory: widget.factory),
                        ),
                      );
                    },
                  ),

                  menuCard(
                    context,
                    "Settings",
                    Icons.settings,
                    Colors.teal,
                    () {},
                  ),
                ],
              ),
              // const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterButton(String title, DashboardFilter filter) {
    final bool isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDashboardFilter() {
    return SegmentedButton<DashboardFilter>(
      segments: const [
        ButtonSegment<DashboardFilter>(
          value: DashboardFilter.today,
          label: Text("Today"),
          icon: Icon(Icons.today),
        ),
        ButtonSegment<DashboardFilter>(
          value: DashboardFilter.thisWeek,
          label: const Text("Week"),
          icon: const Icon(Icons.date_range),
        ),

        ButtonSegment<DashboardFilter>(
          value: DashboardFilter.thisMonth,
          label: const Text("Month"),
          icon: const Icon(Icons.calendar_month),
        ),
      ],
      selected: {selectedFilter},
      onSelectionChanged: (Set<DashboardFilter> selection) {
        setState(() {
          selectedFilter = selection.first;
        });
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

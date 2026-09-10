import 'package:bricks_application/customer/customer_list_screen.dart';
import 'package:bricks_application/dashboard/quick_action_card.dart';
import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/dashboard_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/payment/payment_history_screen.dart';
import 'package:bricks_application/payment/receive_payment_screen.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/repositories/dashboard_repository.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:bricks_application/screens/factory/factory/factory_details_screen.dart';
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

  const FactoryDashboardScreen({super.key, required this.factory});

  @override
  State<FactoryDashboardScreen> createState() => _FactoryDashboardScreenState();
}

class _FactoryDashboardScreenState extends State<FactoryDashboardScreen> {
  final SaleRepository saleRepository = SaleRepository();
  int _selectedIndex = 0;

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

  Widget menuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: .08),
        highlightColor: color.withValues(alpha: .04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .035),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 41,
                width: 41,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 22),
              ),

              const SizedBox(height: 11),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1F2937),
                ),
              ),
            ],
          ),
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
      height: 20,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 11,
                width: 11,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Icon(icon, color: color, size: 11),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(height: 4),
          //  const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: "Poppins",
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xff111827),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  List<CustomerModel> customers = [];
  // Widget menuCard(
  //   BuildContext context,
  //   String title,
  //   IconData icon,
  //   Color color,
  //   VoidCallback onTap,
  // ) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(18),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(.10),
  //         borderRadius: BorderRadius.circular(18),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           CircleAvatar(
  //             radius: 28,
  //             backgroundColor: color.withOpacity(.20),
  //             child: Icon(icon, color: color, size: 28),
  //           ),
  //           const SizedBox(height: 10),
  //           Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563EB).withValues(alpha: .20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.factory_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  widget.factory.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(height: 1, color: Colors.white.withValues(alpha: .15)),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 17,
                color: Colors.white70,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  widget.factory.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: "Poppins",
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              const Icon(Icons.person_outline, size: 17, color: Colors.white70),

              const SizedBox(width: 5),

              Flexible(
                child: Text(
                  widget.factory.owner,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: "Poppins",
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Future<void> _receivePayment() async {
    // 1. Select customer
    final customer = await CustomerSelector.show(context, customers);

    if (customer == null || !mounted) return;

    // 2. Get customer's sales
    final sales = await saleRepository
        .getCustomerSales(widget.factory.id, customer.id)
        .first;

    // 3. Get only pending sales
    final pendingSales = sales.where((sale) => sale.pendingAmount > 0).toList();

    if (!mounted) return;

    // 4. No pending sales
    if (pendingSales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This customer has no pending sales.")),
      );
      return;
    }

    // 5. Select pending sale
    final SaleModel? selectedSale = await showDialog<SaleModel>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Select Pending Sale"),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: ListView.builder(
              itemCount: pendingSales.length,
              itemBuilder: (context, index) {
                final sale = pendingSales[index];

                return ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.blue),
                  title: Text("₹ ${sale.totalAmount.toStringAsFixed(2)}"),
                  subtitle: Text(
                    "Pending: ₹ ${sale.pendingAmount.toStringAsFixed(2)}",
                  ),
                  trailing: Text(
                    sale.brickType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext, sale);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedSale == null || !mounted) return;

    // 6. Navigate to ReceivePaymentScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReceivePaymentScreen(customer: customer, sale: selectedSale),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xff2563EB),
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Factory Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Poppins",
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.factory.name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .75),
                fontFamily: "Poppins",
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) async {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              // Dashboard
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductionListScreen(factory: widget.factory),
                ),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SelectCustomerForSaleScreen(factory: widget.factory),
                ),
              );
              break;

            case 3:
              await _receivePayment();
              break;

            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FactoryManagementScreen(factory: widget.factory),
                ),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => ReportsScreen(factory: widget.factory),
              //   ),
              // );
              // More
              break;
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.factory_outlined),
            selectedIcon: Icon(Icons.factory),
            label: 'Production',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Sales',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
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
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    childAspectRatio: 1.6,
                    children: [
                      buildDashboardCard(
                        "Production",
                        "${data.production.toStringAsFixed(0)} Bricks",
                        Icons.factory,
                        Colors.orange,
                      ),

                      buildDashboardCard(
                        "Bricks Sold",
                        data.salesQuantity.toStringAsFixed(0),
                        Icons.shopping_cart_rounded,
                        Colors.green,
                      ),
                      buildDashboardCard(
                        "Sales",
                        "₹${data.sales.toStringAsFixed(0)}",
                        Icons.currency_rupee_rounded,
                        Colors.green,
                      ),

                      buildDashboardCard(
                        "Collection",
                        "₹${data.collection.toStringAsFixed(0)}",
                        Icons.payments_rounded,
                        Colors.blue,
                      ),

                      buildDashboardCard(
                        "Pending",
                        "₹${data.pending.toStringAsFixed(0)}",
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Text(
                    "Manage your factory quickly",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Color(0xff9CA3AF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 11),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.6,
                children: [
                  // QuickActionCard(
                  //   title: "Production",
                  //   icon: Icons.factory,
                  //   color: Colors.orange,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) =>
                  //             ProductionListScreen(factory: widget.factory),
                  //       ),
                  //     );
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (_) =>
                  //     //         AddProductionScreen(factory: widget.factory),
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                  // QuickActionCard(
                  //   title: "New Sale",
                  //   icon: Icons.shopping_cart,
                  //   color: const Color(0xff2563EB),
                  //   onTap: () {
                  //     selectCustomer();
                  //   },
                  // ),
                  // QuickActionCard(
                  //   title: "New Sale",
                  //   icon: Icons.shopping_cart,
                  //   color: const Color(0xff2563EB),
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => SelectCustomerForSaleScreen(
                  //           factory: widget.factory,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),

                  menuCard(
                    context,
                    "Production",
                    Icons.history,
                    Colors.green,
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
                  menuCard(
                    context,
                    "New Sale",
                    Icons.factory,
                    //   color: Colors.orange,
                    Colors.green,
                    () {
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
                      // 1. Select customer
                      final customer = await CustomerSelector.show(
                        context,
                        customers,
                      );

                      if (customer == null || !mounted) return;

                      // 2. Get customer's sales
                      final sales = await saleRepository
                          .getCustomerSales(widget.factory.id, customer.id)
                          .first;

                      // 3. Get only sales with pending amount
                      final pendingSales = sales
                          .where((sale) => sale.pendingAmount > 0)
                          .toList();

                      if (!mounted) return;

                      // 4. No pending sales
                      if (pendingSales.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "This customer has no pending sales.",
                            ),
                          ),
                        );
                        return;
                      }

                      // 5. Select pending sale
                      final SaleModel?
                      selectedSale = await showDialog<SaleModel>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text("Select Pending Sale"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: 350,
                              child: ListView.builder(
                                itemCount: pendingSales.length,
                                itemBuilder: (context, index) {
                                  final sale = pendingSales[index];

                                  return ListTile(
                                    leading: const Icon(
                                      Icons.receipt_long,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      "₹ ${sale.totalAmount.toStringAsFixed(2)}",
                                    ),
                                    subtitle: Text(
                                      "Pending: ₹ ${sale.pendingAmount.toStringAsFixed(2)}",
                                    ),
                                    trailing: Text(
                                      sale.brickType,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(dialogContext, sale);
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );

                      // 6. User cancelled
                      if (selectedSale == null || !mounted) return;

                      // 7. Open Receive Payment
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceivePaymentScreen(
                            customer: customer,
                            sale: selectedSale,
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
                      // 1. Select customer
                      final customer = await CustomerSelector.show(
                        context,
                        customers,
                      );

                      if (customer == null) return;

                      // 2. Get customer's sales
                      final sales = await saleRepository
                          .getCustomerSales(widget.factory.id, customer.id)
                          .first;

                      // 3. Only show sales that still have pending amount
                      final pendingSales = sales
                          .where((sale) => sale.pendingAmount > 0)
                          .toList();

                      if (!mounted) return;

                      // 4. No pending sales
                      if (pendingSales.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "This customer has no pending sales.",
                            ),
                          ),
                        );
                        return;
                      }

                      // 5. Select pending sale
                      final SaleModel?
                      selectedSale = await showDialog<SaleModel>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Select Pending Sale"),
                            content: SizedBox(
                              width: double.maxFinite,
                              height: 350,
                              child: ListView.builder(
                                itemCount: pendingSales.length,
                                itemBuilder: (context, index) {
                                  final sale = pendingSales[index];

                                  return ListTile(
                                    leading: const Icon(Icons.receipt_long),
                                    title: Text(
                                      "₹ ${sale.totalAmount.toStringAsFixed(2)}",
                                    ),
                                    subtitle: Text(
                                      "Pending: ₹ ${sale.pendingAmount.toStringAsFixed(2)}",
                                    ),
                                    trailing: Text(sale.brickType),
                                    onTap: () {
                                      Navigator.pop(context, sale);
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );

                      // 6. User cancelled sale selection
                      if (selectedSale == null || !mounted) return;

                      // 7. Open Receive Payment with customer + sale
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReceivePaymentScreen(
                            customer: customer,
                            sale: selectedSale,
                          ),
                        ),
                      );
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
              const SizedBox(height: 28),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Factory Management",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff111827),
                  ),
                ),
              ),

              const SizedBox(height: 3),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Manage your factory operations",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Color(0xff9CA3AF),
                  ),
                ),
              ),

              const SizedBox(height: 15),
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
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SegmentedButton<DashboardFilter>(
        segments: const [
          ButtonSegment<DashboardFilter>(
            value: DashboardFilter.today,
            label: Text("Today"),
            icon: Icon(Icons.today_rounded),
          ),
          ButtonSegment<DashboardFilter>(
            value: DashboardFilter.thisWeek,
            label: Text("Week"),
            icon: Icon(Icons.date_range_rounded),
          ),
          ButtonSegment<DashboardFilter>(
            value: DashboardFilter.thisMonth,
            label: Text("Month"),
            icon: Icon(Icons.calendar_month_rounded),
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
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return const Color(0xff6B7280);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xff2563EB);
            }
            return Colors.transparent;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          side: WidgetStateProperty.all(BorderSide.none),
        ),
      ),
    );
  }
  // Widget buildDashboardCard(
  //   String title,
  //   String value,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         CircleAvatar(
  //           backgroundColor: color.withOpacity(.15),
  //           child: Icon(icon, color: color),
  //         ),

  //         const SizedBox(height: 12),

  //         Text(
  //           value,
  //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
  //         ),

  //         const SizedBox(height: 6),

  //         Text(
  //           title,
  //           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

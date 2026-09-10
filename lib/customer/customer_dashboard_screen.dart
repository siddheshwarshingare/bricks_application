import 'package:bricks_application/customer/customer_ledger_screen.dart';
import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/payment/payment_history_screen.dart';
import 'package:bricks_application/payment/receive_payment_screen.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:bricks_application/screens/sale/sale_list_screen.dart';
import 'package:flutter/material.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final FactoryModel factory;
  final CustomerModel customer;
  final SaleRepository saleRepository = SaleRepository();
  CustomerDashboardScreen({
    super.key,
    required this.factory,
    required this.customer,
  });

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  Widget infoCard(String title, String value, IconData icon, Color color) {
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
            radius: 24,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 5),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> receivePayment(BuildContext context) async {
    final sales = await widget.saleRepository
        .getCustomerSales(widget.factory.id, widget.customer.id)
        .first;

    final pendingSales = sales.where((sale) => sale.pendingAmount > 0).toList();

    if (!context.mounted) return;

    if (pendingSales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This customer has no pending sales.")),
      );
      return;
    }

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
                  leading: const Icon(Icons.receipt_long),
                  title: Text("₹ ${sale.totalAmount.toStringAsFixed(2)}"),
                  subtitle: Text(
                    "Pending: ₹ ${sale.pendingAmount.toStringAsFixed(2)}",
                  ),
                  trailing: Text(sale.brickType),
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

    if (selectedSale == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReceivePaymentScreen(customer: widget.customer, sale: selectedSale),
      ),
    );
  }

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
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: .20),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paidAmount =
        widget.customer.totalPurchase - widget.customer.pendingBalance;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(title: Text(widget.customer.name), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Customer Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customer Information",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.customer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        widget.customer.mobile,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.customer.address,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.home_work, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.customer.village,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.customer.gstNumber.isEmpty
                              ? "Not Available"
                              : widget.customer.gstNumber,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Summary Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                infoCard(
                  "Total Purchase",
                  "₹${widget.customer.totalPurchase.toStringAsFixed(0)}",
                  Icons.shopping_cart,
                  Colors.green,
                ),

                infoCard(
                  "Pending",
                  "₹${widget.customer.pendingBalance.toStringAsFixed(0)}",
                  Icons.pending_actions,
                  Colors.red,
                ),

                infoCard(
                  "Paid",
                  "₹${paidAmount.toStringAsFixed(0)}",
                  Icons.payments,
                  Colors.blue,
                ),

                infoCard(
                  "Opening Balance",
                  "₹${widget.customer.openingBalance.toStringAsFixed(0)}",
                  Icons.account_balance_wallet,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 11),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Quick Actions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: .9,
              children: [
                menuCard(context, "Sales", Icons.sell, Colors.orange, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SaleListScreen(
                        factory: widget.factory,
                        customer: widget.customer,
                      ),
                    ),
                  );
                }),
                /**
 * Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      const Text(
        "Quick Actions",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      const SizedBox(height: 15),

      Row(
        children: [

          QuickActionCard(
            title: "Production",
            icon: Icons.factory,
            color: Colors.orange,
            onTap: () {
              // Navigate Production
            },
          ),

          QuickActionCard(
            title: "Sale",
            icon: Icons.shopping_cart,
            color: Colors.green,
            onTap: () {
              // Navigate Sales
            },
          ),
        ],
      ),

      Row(
        children: [

          QuickActionCard(
            title: "Payment",
            icon: Icons.payments,
            color: Colors.blue,
            onTap: () {
              // Navigate Payment
            },
          ),

          QuickActionCard(
            title: "Customer",
            icon: Icons.people,
            color: Colors.purple,
            onTap: () {
              // Navigate Customer
            },
          ),
        ],
      ),
    ],
  ),
),
 */
                // menuCard(
                //   context,
                //   "Receive Payment",
                //   Icons.payments,
                //   Colors.blue,
                //   () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => ReceivePaymentScreen(
                //           customer: widget.customer,
                //           sale: null,
                //         ),
                //       ),
                //     );
                //   },
                // ),
                menuCard(
                  context,
                  "Receive Payment",
                  Icons.payments,
                  Colors.blue,
                  () => receivePayment(context),
                ),

                menuCard(
                  context,
                  "Payment History",
                  Icons.history,
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PaymentHistoryScreen(customer: widget.customer),
                      ),
                    );
                  },
                ),
                // ListTile(
                //   leading: const Icon(Icons.history),
                //   title: const Text("Payment History"),
                //   trailing: const Icon(Icons.arrow_forward_ios),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) =>
                //             PaymentHistoryScreen(customer: customer),
                //       ),
                //     );
                //   },
                // ),
                menuCard(
                  context,
                  "Customer Ledger",
                  Icons.menu_book,
                  Colors.deepPurple,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CustomerLedgerScreen(customer: widget.customer),
                      ),
                    );
                  },
                ),
                menuCard(
                  context,
                  "Sales History",
                  Icons.history,
                  Colors.orange,
                  () {
                    // TODO
                  },
                ),

                menuCard(
                  context,
                  "Reports",
                  Icons.bar_chart,
                  Colors.purple,
                  () {
                    // TODO
                  },
                ),

                menuCard(context, "Invoices", Icons.receipt, Colors.teal, () {
                  // TODO
                }),

                menuCard(context, "Print", Icons.print, Colors.indigo, () {
                  // TODO
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

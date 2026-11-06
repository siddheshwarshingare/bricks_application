import 'package:bricks_application/customer/add_customer_screen.dart';
import 'package:bricks_application/customer/customer_dashboard_screen.dart';
import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:bricks_application/services/invoice_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerListScreen extends StatefulWidget {
  final FactoryModel factory;

  const CustomerListScreen({super.key, required this.factory});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final CustomerRepository repository = CustomerRepository();
  final SaleRepository saleRepository = SaleRepository();

  final TextEditingController searchController = TextEditingController();

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Customer"),
        content: const Text("Are you sure you want to delete this customer?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> changeDeliveryStatus({
    required SaleModel sale,
    required String status,
  }) async {
    try {
      await saleRepository.updateDeliveryStatus(
        factoryId: widget.factory.id,
        saleId: sale.id,
        status: status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order marked as $status'),
          backgroundColor: status == 'Delivered' ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update delivery status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget deliveryStatusDropdown(SaleModel sale) {
    final status = sale.deliveryStatus == 'Delivered' ? 'Delivered' : 'Pending';

    final isDelivered = status == 'Delivered';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: isDelivered ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDelivered ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: status,
          isDense: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: isDelivered ? Colors.green.shade800 : Colors.orange.shade800,
          ),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDelivered ? Colors.green.shade800 : Colors.orange.shade900,
          ),
          items: const [
            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
            DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
          ],
          onChanged: (value) {
            if (value == null || value == status) return;

            changeDeliveryStatus(sale: sale, status: value);
          },
        ),
      ),
    );
  }

  Widget infoRow({required IconData icon, required String text, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget customerCard({
    required CustomerModel customer,
    required SaleModel? latestSale,
  }) {
    return Dismissible(
      key: Key(customer.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await deleteDialog();
      },
      onDismissed: (_) async {
        try {
          await repository.deleteCustomer(widget.factory.id, customer.id);

          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("${customer.name} deleted")));
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Delete failed: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 25),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAECF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.person, color: Colors.blue, size: 25),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF202938),
                        ),
                      ),
                      const SizedBox(height: 8),

                      infoRow(icon: Icons.phone, text: customer.mobile),

                      infoRow(
                        icon: Icons.inventory_2_outlined,
                        text:
                            'Purchased: ${customer.totalQuantity.toStringAsFixed(0)} Bricks',
                      ),

                      infoRow(
                        icon: Icons.currency_rupee,
                        text:
                            'Purchase: ₹${customer.totalPurchase.toStringAsFixed(0)}',
                      ),

                      infoRow(
                        icon: Icons.account_balance_wallet_outlined,
                        text: 'Paid: ₹${customer.totalPaid.toStringAsFixed(0)}',
                      ),

                      infoRow(
                        icon: Icons.location_on_outlined,
                        text: 'Village: ${customer.village}',
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Pending: ₹${customer.pendingBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      if (latestSale != null) ...[
                        const SizedBox(height: 12),
                        Divider(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 15,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'LATEST ORDER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  color: Color(0xFF667085),
                                ),
                              ),
                            ),
                            deliveryStatusDropdown(latestSale),
                          ],
                        ),

                        const SizedBox(height: 8),

                        infoRow(
                          icon: Icons.inventory_2_outlined,
                          text: latestSale.productName,
                          color: Colors.black87,
                        ),

                        infoRow(
                          icon: Icons.numbers,
                          text:
                              'Quantity: ${latestSale.quantity.toStringAsFixed(0)} Bricks',
                        ),

                        infoRow(
                          icon: Icons.calendar_today_outlined,
                          text:
                              'Order Date: ${formatDate(latestSale.saleDate)}',
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        Text(
                          'No orders placed yet',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 2),

                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                  onSelected: (value) async {
                    try {
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
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invoice operation failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: "generate",
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "${widget.factory.name} Customers",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 30),
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Customer",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF667085)),
                filled: true,
                fillColor: const Color(0xFFF5F6F8),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
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
              builder: (context, customerSnapshot) {
                if (customerSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (customerSnapshot.hasError) {
                  return Center(child: Text(customerSnapshot.error.toString()));
                }

                final customers = customerSnapshot.data ?? [];

                final filteredCustomers = customers.where((customer) {
                  return customer.name.toLowerCase().contains(search) ||
                      customer.mobile.contains(search);
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 55,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "No Customers Found",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Get all sales. getSales() already orders them
                // by saleDate descending (latest sale first).
                return StreamBuilder<List<SaleModel>>(
                  stream: saleRepository.getSales(widget.factory.id),
                  builder: (context, salesSnapshot) {
                    if (salesSnapshot.hasError) {
                      return Center(
                        child: Text(salesSnapshot.error.toString()),
                      );
                    }

                    if (salesSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !salesSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final sales = salesSnapshot.data ?? [];

                    // First sale encountered for each customer is
                    // their latest sale because getSales is descending.
                    final Map<String, SaleModel> latestSales = {};

                    for (final sale in sales) {
                      latestSales.putIfAbsent(sale.customerId, () => sale);
                    }

                    // Customers with latest orders appear first.
                    // Customers without orders appear afterwards.
                    filteredCustomers.sort((a, b) {
                      final saleA = latestSales[a.id];
                      final saleB = latestSales[b.id];

                      if (saleA == null && saleB == null) return 0;
                      if (saleA == null) return 1;
                      if (saleB == null) return -1;

                      return saleB.saleDate.compareTo(saleA.saleDate);
                    });

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 90),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];

                        return customerCard(
                          customer: customer,
                          latestSale: latestSales[customer.id],
                        );
                      },
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

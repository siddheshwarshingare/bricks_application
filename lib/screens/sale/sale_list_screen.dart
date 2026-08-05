import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:bricks_application/screens/sale/add_sale_screen.dart';
import 'package:flutter/material.dart';

class SaleListScreen extends StatefulWidget {
  final FactoryModel factory;
  final CustomerModel customer;

  const SaleListScreen({
    super.key,
    required this.factory,
    required this.customer,
  });

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  final SaleRepository repository = SaleRepository();

  final TextEditingController searchController = TextEditingController();

  String search = "";

  String filter = "All";

  final filters = ["All", "Today", "Week", "Month", "Year"];
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<SaleModel> applyFilter(List<SaleModel> sales) {
    DateTime now = DateTime.now();

    return sales.where((sale) {
      final date = sale.saleDate.toDate();

      if (search.isNotEmpty &&
          !sale.customerName.toLowerCase().contains(search.toLowerCase())) {
        return false;
      }

      switch (filter) {
        case "Today":
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

        case "Week":
          return now.difference(date).inDays <= 7;

        case "Month":
          return date.month == now.month && date.year == now.year;

        case "Year":
          return date.year == now.year;

        default:
          return true;
      }
    }).toList();
  }

  Future<void> deleteSale(SaleModel sale) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Sale"),
        content: const Text("Are you sure you want to delete this sale?"),
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

    if (result == true) {
      await repository.deleteSale(widget.factory.id, sale.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sale Deleted")));
    }
  }

  Widget buildSummary(List<SaleModel> sales) {
    double total = 0;
    double paid = 0;
    double pending = 0;

    for (var sale in sales) {
      total += sale.totalAmount;
      paid += sale.paidAmount;
      pending += sale.pendingAmount;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Sales"),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Received"),
                Text(
                  "₹${paid.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pending"),
                Text(
                  "₹${pending.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSaleCard(SaleModel sale) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),

        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.orange.shade100,
          child: const Icon(Icons.sell, color: Colors.orange),
        ),

        title: Text(
          sale.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Text("Brick : ${sale.brickType}"),

            Text("Qty : ${sale.quantity}"),

            Text("Rate : ₹${sale.rate}"),

            Text(
              "Date : ${sale.saleDate.toDate().day}/"
              "${sale.saleDate.toDate().month}/"
              "${sale.saleDate.toDate().year}",
            ),

            const SizedBox(height: 5),
            Text(
              "Paid Amount : ₹${sale.paidAmount}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Pending : ₹${sale.pendingAmount}",
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSaleScreen(
                    factory: widget.factory,
                    customer: widget.customer,
                    sale: sale,
                  ),
                ),
              );
            }

            if (value == "delete") {
              deleteSale(sale);
            }
          },

          itemBuilder: (_) => const [
            PopupMenuItem(
              value: "edit",
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 10), Text("Edit")],
              ),
            ),

            PopupMenuItem(
              value: "delete",
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 10),
                  Text("Delete"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),

      child: DropdownButtonFormField<String>(
        value: filter,

        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),

        items: filters.map((e) {
          return DropdownMenuItem(value: e, child: Text(e));
        }).toList(),

        onChanged: (value) {
          setState(() {
            filter = value!;
          });
        },
      ),
    );
  }

  Widget buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: TextField(
        controller: searchController,

        decoration: InputDecoration(
          hintText: "Search Customer",

          prefixIcon: const Icon(Icons.search),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),

        onChanged: (value) {
          setState(() {
            search = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sales")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSaleScreen(
                factory: widget.factory,
                customer: widget.customer,
              ),
            ),
          );
        },
      ),

      body: Column(
        children: [
          buildSearch(),

          buildFilter(),

          Expanded(
            child: StreamBuilder<List<SaleModel>>(
              stream: repository.getCustomerSales(
                widget.factory.id,
                widget.customer.id,
              ),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final sales = applyFilter(snapshot.data ?? []);

                if (sales.isEmpty) {
                  return const Center(child: Text("No Sales Found"));
                }

                return Column(
                  children: [
                    buildSummary(sales),

                    Expanded(
                      child: ListView.builder(
                        itemCount: sales.length,

                        itemBuilder: (_, index) {
                          return buildSaleCard(sales[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

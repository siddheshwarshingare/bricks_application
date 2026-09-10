import 'package:bricks_application/models/customer_model.dart';
import 'package:flutter/material.dart';

class CustomerSelector {
  static Future<CustomerModel?> show(
    BuildContext context,
    List<CustomerModel> customers,
  ) async {
    if (customers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No Customers Found")));
      return null;
    }

    return await showDialog<CustomerModel>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Select Customer"),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(customer.name),
                  subtitle: Text(customer.mobile),
                  onTap: () {
                    Navigator.pop(context, customer);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

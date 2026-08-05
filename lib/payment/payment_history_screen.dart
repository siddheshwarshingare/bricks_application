import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/payment_model.dart';
import 'package:bricks_application/repositories/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final CustomerModel customer;

  PaymentHistoryScreen({super.key, required this.customer});

  final PaymentRepository repository = PaymentRepository();

  Color getColor(String method) {
    switch (method) {
      case "Cash":
        return Colors.green;

      case "UPI":
        return Colors.blue;

      case "Cheque":
        return Colors.orange;

      case "Bank Transfer":
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  IconData getIcon(String method) {
    switch (method) {
      case "Cash":
        return Icons.money;

      case "UPI":
        return Icons.qr_code;

      case "Cheque":
        return Icons.receipt_long;

      case "Bank Transfer":
        return Icons.account_balance;

      default:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment History"), centerTitle: true),

      body: StreamBuilder<List<PaymentModel>>(
        stream: repository.getCustomerPayments(customer.factoryId, customer.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return const Center(
              child: Text("No Payment Found", style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: getColor(
                              payment.paymentMethod,
                            ).withOpacity(.15),
                            child: Icon(
                              getIcon(payment.paymentMethod),
                              color: getColor(payment.paymentMethod),
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  payment.paymentMethod,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  DateFormat(
                                    "dd MMM yyyy",
                                  ).format(payment.paymentDate.toDate()),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "₹ ${payment.amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      if (payment.referenceNumber.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              const Text(
                                "Reference : ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Text(payment.referenceNumber)),
                            ],
                          ),
                        ),

                      if (payment.remarks.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Remarks : ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(child: Text(payment.remarks)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

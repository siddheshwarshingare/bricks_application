import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/payment_model.dart';
import 'package:bricks_application/repositories/payment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReceivePaymentScreen extends StatefulWidget {
  final CustomerModel customer;

  const ReceivePaymentScreen({super.key, required this.customer});

  @override
  State<ReceivePaymentScreen> createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final PaymentRepository repository = PaymentRepository();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  DateTime paymentDate = DateTime.now();

  String paymentMethod = "Cash";

  bool isLoading = false;

  final List<String> paymentMethods = [
    "Cash",
    "UPI",
    "Bank Transfer",
    "Cheque",
  ];

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        paymentDate = picked;
      });
    }
  }

  Future<void> savePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(amountController.text);

    if (amount > widget.customer.pendingBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment cannot exceed pending amount.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final payment = PaymentModel(
        id: "",
        factoryId: widget.customer.factoryId,
        customerId: widget.customer.id,
        customerName: widget.customer.name,
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceController.text.trim(),
        remarks: remarksController.text.trim(),
        paymentDate: Timestamp.fromDate(paymentDate),
        createdAt: Timestamp.now(),
      );

      await repository.addPayment(payment);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Received Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receive Payment"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// Customer Information
              Card(
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
                          const CircleAvatar(
                            radius: 25,
                            child: Icon(Icons.person),
                          ),
                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.customer.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(widget.customer.mobile),

                                Text(widget.customer.village),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Current Pending",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          Text(
                            "₹ ${widget.customer.pendingBalance.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Payment Amount
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Payment Amount",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter payment amount";
                  }

                  if (double.tryParse(value) == null) {
                    return "Invalid amount";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              /// Payment Method
              DropdownButtonFormField<String>(
                value: paymentMethod,
                decoration: const InputDecoration(
                  labelText: "Payment Method",
                  border: OutlineInputBorder(),
                ),
                items: paymentMethods.map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              /// Reference Number
              TextFormField(
                controller: referenceController,
                decoration: const InputDecoration(
                  labelText: "Reference Number (Optional)",
                  prefixIcon: Icon(Icons.receipt_long),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              /// Remarks
              TextFormField(
                controller: remarksController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              /// Payment Date
              InkWell(
                onTap: selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "${paymentDate.day}-${paymentDate.month}-${paymentDate.year}",
                        ),
                      ),

                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : savePayment,
                  icon: const Icon(Icons.payments),
                  label: Text(isLoading ? "Please Wait..." : "Receive Payment"),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

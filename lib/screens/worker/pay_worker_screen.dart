import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/models/worker_payment_model.dart';
import 'package:bricks_application/repositories/worker_payment_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PayWorkerScreen extends StatefulWidget {
  final WorkerModel worker;

  const PayWorkerScreen({super.key, required this.worker});

  @override
  State<PayWorkerScreen> createState() => _PayWorkerScreenState();
}

class _PayWorkerScreenState extends State<PayWorkerScreen> {
  final _formKey = GlobalKey<FormState>();

  final WorkerPaymentRepository repository = WorkerPaymentRepository();

  final amountController = TextEditingController();
  final remarksController = TextEditingController();

  DateTime paymentDate = DateTime.now();

  String paymentMethod = "Cash";

  bool isLoading = false;

  final List<String> paymentMethods = [
    "Cash",
    "UPI",
    "Bank Transfer",
    "Cheque",
  ];

  @override
  void dispose() {
    amountController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
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

    setState(() {
      isLoading = true;
    });

    try {
      final payment = WorkerPaymentModel(
        id: "",
        factoryId: widget.worker.factoryId,
        workerId: widget.worker.id,
        workerName: widget.worker.name,
        amount: double.parse(amountController.text),
        paymentMethod: paymentMethod,
        remarks: remarksController.text.trim(),
        paymentDate: Timestamp.fromDate(paymentDate),
        createdAt: Timestamp.now(),
      );

      await repository.addPayment(payment);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Salary Paid Successfully")));

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
      appBar: AppBar(title: const Text("Pay Worker")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              /// Worker Info
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(widget.worker.name),
                  subtitle: Text(widget.worker.mobile),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Salary Amount",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter amount";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
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

              InkWell(
                onTap: pickDate,
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

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payments),
                  label: Text(isLoading ? "Please Wait..." : "Pay Salary"),
                  onPressed: isLoading ? null : savePayment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

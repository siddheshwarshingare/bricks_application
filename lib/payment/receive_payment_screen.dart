import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReceivePaymentScreen extends StatefulWidget {
  final CustomerModel customer;
  final SaleModel sale;
  const ReceivePaymentScreen({
    super.key,
    required this.customer,
    required this.sale,
  });

  @override
  State<ReceivePaymentScreen> createState() => _ReceivePaymentScreenState();
}

class _ReceivePaymentScreenState extends State<ReceivePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final SaleRepository repository = SaleRepository();
  SaleModel? currentSale;
  CustomerModel? currentCustomer;
  bool loadingSale = true;

  @override
  void initState() {
    super.initState();

    currentSale = widget.sale;
    _loadLatestSale();
  }

  Future<void> _loadLatestSale() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final saleRef = firestore
          .collection('factories')
          .doc(widget.sale.factoryId)
          .collection('sales')
          .doc(widget.sale.id);

      final customerRef = firestore
          .collection('factories')
          .doc(widget.sale.factoryId)
          .collection('customers')
          .doc(widget.customer.id);

      // Get latest values from SERVER
      final results = await Future.wait([
        saleRef.get(const GetOptions(source: Source.server)),
        customerRef.get(const GetOptions(source: Source.server)),
      ]);

      final saleDoc = results[0];
      final customerDoc = results[1];

      if (!mounted) return;

      if (!saleDoc.exists) {
        setState(() {
          loadingSale = false;
          currentSale = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This sale no longer exists.")),
        );

        return;
      }

      final latestSale = SaleModel.fromFirestore(saleDoc);

      CustomerModel? latestCustomer;

      if (customerDoc.exists) {
        latestCustomer = CustomerModel.fromFirestore(customerDoc);
      }

      setState(() {
        currentSale = latestSale;
        currentCustomer = latestCustomer;
        loadingSale = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingSale = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to load latest payment information: $e"),
        ),
      );
    }
  }

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

    if (currentSale == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sale information is not available.")),
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid payment amount.")),
      );
      return;
    }

    // ALWAYS use latest Firestore sale
    final pendingAmount = currentSale!.pendingAmount;

    if (pendingAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This sale has no pending amount.")),
      );
      return;
    }

    if (amount > pendingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Payment cannot exceed pending amount of ₹${pendingAmount.toStringAsFixed(2)}",
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await repository.addPaymentToSale(
        sale: currentSale!,
        customer: currentCustomer ?? widget.customer,
        amount: amount,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        referenceNumber: referenceController.text.trim(),
        remarks: remarksController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Received Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  // Future<void> savePayment() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final amount = double.parse(amountController.text);

  //   if (amount > widget.customer.pendingBalance) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Payment cannot exceed pending amount.")),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     await repository.addPaymentToSale(
  //       sale: widget.sale,
  //       customer: widget.customer,
  //       amount: amount,

  //       paymentDate: paymentDate,

  //       paymentMethod: paymentMethod,
  //       referenceNumber: referenceController.text.trim(),
  //       remarks: remarksController.text.trim(),
  //     );

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Payment Received Successfully")),
  //     );

  //     Navigator.pop(context);
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text(e.toString())));
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Receive Payment tt",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xff2563EB),
        centerTitle: true,
      ),
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

                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Selected Sale Pending",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                loadingSale
                                    ? "Loading..."
                                    : "₹ ${(currentSale?.pendingAmount ?? 0).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Customer Total Pending",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                loadingSale
                                    ? "Loading..."
                                    : "₹ ${(currentCustomer?.pendingBalance ?? 0).toStringAsFixed(2)}",
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

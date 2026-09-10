import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSaleScreen extends StatefulWidget {
  final FactoryModel factory;
  final CustomerModel customer;
  final SaleModel? sale;
  const AddSaleScreen({
    super.key,
    required this.factory,
    required this.customer,
    this.sale,
  });

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  final SaleRepository repository = SaleRepository();

  late TextEditingController quantityController;
  late TextEditingController rateController;
  late TextEditingController paidController;
  late TextEditingController vehicleController;
  late TextEditingController remarksController;

  DateTime saleDate = DateTime.now();

  String brickType = "Red Brick";

  double totalAmount = 0;
  double pendingAmount = 0;

  final List<String> brickTypes = [
    "Red Brick",
    "Fly Ash Brick",
    "Cement Brick",
    "Concrete Block",
  ];
  Future<void> saveSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity = double.parse(quantityController.text);
    final rate = double.parse(rateController.text);
    final paid = double.parse(paidController.text);

    final total = quantity * rate;
    final pending = total - paid;

    final sale = SaleModel(
      id: widget.sale?.id ?? "",
      factoryId: widget.factory.id,
      customerId: widget.customer.id,
      customerName: widget.customer.name,

      brickType: brickType,

      quantity: quantity,
      rate: rate,

      totalAmount: total,
      paidAmount: paid,
      pendingAmount: pending,

      vehicleNumber: vehicleController.text.trim(),
      remarks: remarksController.text.trim(),

      saleDate: Timestamp.fromDate(saleDate),
      createdAt: widget.sale?.createdAt ?? Timestamp.now(),
    );

    try {
      if (widget.sale == null) {
        await repository.addSale(sale, widget.customer);
      } else {
        await repository.updateSale(sale);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.sale == null
                ? "Sale Added Successfully"
                : "Sale Updated Successfully",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Enter $label";
          }
          return null;
        },
      ),
    );
  }

  Widget buildBrickDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: brickType,
        decoration: InputDecoration(
          labelText: "Brick Type",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: brickTypes.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }).toList(),
        onChanged: (value) {
          setState(() {
            brickType = value!;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    quantityController = TextEditingController();
    rateController = TextEditingController();
    paidController = TextEditingController(text: "0");
    vehicleController = TextEditingController();
    remarksController = TextEditingController();

    quantityController.addListener(calculateTotal);
    rateController.addListener(calculateTotal);
    paidController.addListener(calculateTotal);
  }

  @override
  void dispose() {
    quantityController.dispose();
    rateController.dispose();
    paidController.dispose();
    vehicleController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  void calculateTotal() {
    final quantity = double.tryParse(quantityController.text) ?? 0;

    final rate = double.tryParse(rateController.text) ?? 0;

    final paid = double.tryParse(paidController.text) ?? 0;

    setState(() {
      totalAmount = quantity * rate;
      pendingAmount = totalAmount - paid;

      if (pendingAmount < 0) {
        pendingAmount = 0;
      }
    });
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        saleDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sale == null ? "Add Sale" : "Edit Sale"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Customer Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Customer Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Divider(),

                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(widget.customer.name),
                        subtitle: Text(widget.customer.mobile),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Sale Date
              InkWell(
                onTap: selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Sale Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    "${saleDate.day}/${saleDate.month}/${saleDate.year}",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// Brick Type
              buildBrickDropdown(),

              /// Quantity
              buildTextField(
                controller: quantityController,
                label: "Quantity",
                keyboardType: TextInputType.number,
              ),

              /// Rate
              buildTextField(
                controller: rateController,
                label: "Rate",
                keyboardType: TextInputType.number,
              ),

              /// Paid Amount
              buildTextField(
                controller: paidController,
                label: "Paid Amount",
                keyboardType: TextInputType.number,
              ),

              /// Vehicle Number
              buildTextField(
                controller: vehicleController,
                label: "Vehicle Number",
              ),

              /// Remarks
              buildTextField(
                controller: remarksController,
                label: "Remarks",
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              /// Summary Card
              Card(
                color: Colors.blue.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "₹ ${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Pending Amount",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "₹ ${pendingAmount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: saveSale,
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.sale == null ? "Save Sale" : "Update Sale",
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:bricks_application/models/customer_model.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCustomerScreen extends StatefulWidget {
  final FactoryModel factory;
  final CustomerModel? customer;

  const AddCustomerScreen({super.key, required this.factory, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  final CustomerRepository repository = CustomerRepository();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final villageController = TextEditingController();
  final gstController = TextEditingController();
  final openingBalanceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.customer != null) {
      nameController.text = widget.customer!.name;
      mobileController.text = widget.customer!.mobile;
      addressController.text = widget.customer!.address;
      villageController.text = widget.customer!.village;
      gstController.text = widget.customer!.gstNumber;
      openingBalanceController.text = widget.customer!.openingBalance
          .toString();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    villageController.dispose();
    gstController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final openingBalance =
        double.tryParse(openingBalanceController.text.trim()) ?? 0;

    final customer = CustomerModel(
      id: widget.customer?.id ?? "",
      factoryId: widget.factory.id,
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      address: addressController.text.trim(),
      village: villageController.text.trim(),
      gstNumber: gstController.text.trim(),
      openingBalance: openingBalance,
      pendingBalance: widget.customer?.pendingBalance ?? openingBalance,
      totalPurchase: widget.customer?.totalPurchase ?? 0,
      createdAt: widget.customer?.createdAt ?? Timestamp.now(),
      totalPaid: widget.customer?.totalPaid ?? 0,
      totalQuantity: widget.customer?.totalQuantity ?? 0,
    );

    if (widget.customer == null) {
      await repository.addCustomer(customer);
    } else {
      await repository.updateCustomer(customer);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.customer == null
              ? "Customer Added Successfully"
              : "Customer Updated Successfully",
        ),
      ),
    );

    Navigator.pop(context);
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customer == null ? "Add Customer" : "Edit Customer",
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
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: inputDecoration("Customer Name"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter customer name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: inputDecoration("Mobile Number"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter mobile number";
                  }

                  if (value.length != 10) {
                    return "Enter valid mobile number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: addressController,
                decoration: inputDecoration("Address"),
                maxLines: 2,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: villageController,
                decoration: inputDecoration("Village"),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: gstController,
                decoration: inputDecoration("GST Number (Optional)"),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: openingBalanceController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration("Opening Balance"),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.customer == null
                        ? "Save Customer"
                        : "Update Customer",
                  ),
                  onPressed: saveCustomer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

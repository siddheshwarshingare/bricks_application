import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/material_model.dart';
import 'package:bricks_application/repositories/material_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMaterialScreen extends StatefulWidget {
  final FactoryModel factory;
  final MaterialModel? material;

  const AddMaterialScreen({super.key, required this.factory, this.material});

  @override
  State<AddMaterialScreen> createState() => _AddMaterialScreenState();
}

class _AddMaterialScreenState extends State<AddMaterialScreen> {
  final _formKey = GlobalKey<FormState>();

  final MaterialRepository repository = MaterialRepository();

  final materialController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final supplierController = TextEditingController();
  final remarksController = TextEditingController();

  final List<String> units = ["Kg", "Ton", "Bag", "Liter", "Piece", "Brass"];

  String selectedUnit = "Kg";

  DateTime purchaseDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.material != null) {
      materialController.text = widget.material!.materialName;
      quantityController.text = widget.material!.quantity.toString();
      priceController.text = widget.material!.price.toString();
      supplierController.text = widget.material!.supplier;
      remarksController.text = widget.material!.remarks;
      selectedUnit = widget.material!.unit;
      purchaseDate = widget.material!.purchaseDate.toDate();
    }
  }

  @override
  void dispose() {
    materialController.dispose();
    quantityController.dispose();
    priceController.dispose();
    supplierController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> saveMaterial() async {
    if (!_formKey.currentState!.validate()) return;

    final material = MaterialModel(
      id: widget.material?.id ?? "",
      factoryId: widget.factory.id,
      materialName: materialController.text.trim(),
      quantity: double.parse(quantityController.text),
      unit: selectedUnit,
      price: double.parse(priceController.text),
      supplier: supplierController.text.trim(),
      remarks: remarksController.text.trim(),
      purchaseDate: Timestamp.fromDate(purchaseDate),
      createdAt: widget.material?.createdAt ?? Timestamp.now(),
    );

    if (widget.material == null) {
      await repository.addMaterial(material);
    } else {
      await repository.updateMaterial(material);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.material == null
              ? "Material Added Successfully"
              : "Material Updated Successfully",
        ),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: purchaseDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        purchaseDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.material == null ? "Add Material" : "Edit Material"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: materialController,
                decoration: const InputDecoration(
                  labelText: "Material Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter Material Name" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter Quantity" : null,
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: selectedUnit,
                decoration: const InputDecoration(
                  labelText: "Unit",
                  border: OutlineInputBorder(),
                ),
                items: units.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter Price" : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: supplierController,
                decoration: const InputDecoration(
                  labelText: "Supplier",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: "Remarks",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 15),

              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  "${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}",
                ),
                trailing: ElevatedButton(
                  onPressed: pickDate,
                  child: const Text("Select Date"),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: saveMaterial,
                  child: Text(
                    widget.material == null
                        ? "Save Material"
                        : "Update Material",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

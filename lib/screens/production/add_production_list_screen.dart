import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/repositories/worker_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProductionScreen extends StatefulWidget {
  final FactoryModel factory;
  final ProductionModel? production;

  const AddProductionScreen({
    super.key,
    required this.factory,
    this.production,
  });

  @override
  State<AddProductionScreen> createState() => _AddProductionScreenState();
}

class _AddProductionScreenState extends State<AddProductionScreen> {
  final _formKey = GlobalKey<FormState>();

  final ProductionRepository repository = ProductionRepository();
  final WorkerRepository workerRepository = WorkerRepository();
  final salaryEarned = TextEditingController();
  final bricksController = TextEditingController();
  final remarksController = TextEditingController();
  final rateController = TextEditingController();
  final salaryController = TextEditingController();
  final cashReturnedController = TextEditingController();
  final salaryPaidController = TextEditingController();
  WorkerModel? selectedWorker;

  DateTime selectedDate = DateTime.now();
  void calculateSalary() {
    final bricks = int.tryParse(bricksController.text) ?? 0;
    final rate = double.tryParse(rateController.text) ?? 0;

    final salary = (bricks / 1000) * rate;

    salaryController.text = salary.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();

    if (widget.production != null) {
      bricksController.text = widget.production!.bricksProduced.toString();

      remarksController.text = widget.production!.remarks;

      selectedDate = widget.production!.productionDate.toDate();
    }
  }

  InputDecoration appInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE5E7EB)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE5E7EB)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff2563EB), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    bricksController.dispose();
    remarksController.dispose();
    rateController.dispose();
    salaryController.dispose();
    cashReturnedController.dispose();
    salaryPaidController.dispose();
    salaryEarned.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2050),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> saveProduction() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedWorker == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select worker")));
      return;
    }

    final production = ProductionModel(
      id: widget.production?.id ?? "",
      factoryId: widget.factory.id,
      workerId: selectedWorker!.id,
      workerName: selectedWorker!.name,
      bricksProduced: int.parse(bricksController.text),
      remarks: remarksController.text.trim(),
      productionDate: Timestamp.fromDate(selectedDate),
      createdAt: widget.production?.createdAt ?? Timestamp.now(),
      ratePer1000: selectedWorker!.ratePer1000,

      salaryPaid: double.tryParse(salaryPaidController.text) ?? 0,
      salaryEarned: double.tryParse(salaryController.text) ?? 0,
      cashReturned: double.tryParse(cashReturnedController.text) ?? 0,
    );

    if (widget.production == null) {
      await repository.addProduction(production);
    } else {
      await repository.updateProduction(production);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.production == null ? "Production Added" : "Production Updated",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.production == null ? "Add Production" : "Edit Production",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xff2563EB),
      ),
      body: StreamBuilder<List<WorkerModel>>(
        stream: workerRepository.getWorkers(widget.factory.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final workers = snapshot.data ?? [];

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<WorkerModel>(
                  value: selectedWorker,
                  decoration: const InputDecoration(
                    labelText: "Select Worker",
                    border: OutlineInputBorder(),
                  ),
                  items: workers.map((worker) {
                    return DropdownMenuItem(
                      value: worker,
                      child: Text(worker.name),
                    );
                  }).toList(),
                  onChanged: (worker) {
                    setState(() {
                      selectedWorker = worker;

                      rateController.text =
                          worker?.ratePer1000.toStringAsFixed(0) ?? "0";

                      calculateSalary();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Select worker";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: bricksController,
                  keyboardType: TextInputType.number,
                  decoration: appInputDecoration("Bricks Produced"),
                  onChanged: (_) => calculateSalary(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter production";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: rateController,
                  keyboardType: TextInputType.number,
                  decoration: appInputDecoration("Rate / 1000"),
                  onChanged: (_) => calculateSalary(),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: salaryController,
                  readOnly: true,
                  decoration: appInputDecoration("Salary Earned"),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: cashReturnedController,
                  keyboardType: TextInputType.number,
                  decoration: appInputDecoration("Cash Returned"),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: salaryPaidController,
                  keyboardType: TextInputType.number,
                  decoration: appInputDecoration("Salary Paid"),
                ),
                // TextFormField(
                //   controller: salaryPaidController,
                //   keyboardType: TextInputType.number,
                //   decoration: appInputDecoration("Salary Paid"),
                // ),
                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text("Production Date"),
                  subtitle: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                  trailing: ElevatedButton(
                    onPressed: pickDate,
                    child: const Text("Select"),
                  ),
                ),

                const SizedBox(height: 30),

                // SizedBox(
                //   height: 55,
                //   child: ElevatedButton(
                //     onPressed: saveProduction,
                //     child: Text(
                //       widget.production == null
                //           ? "Save Production"
                //           : "Update Production",
                //     ),
                //   ),
                // ),
                SizedBox(
                  height: 56,
                  width: double.infinity,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: saveProduction,
                    child: Text(
                      "Save Production",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

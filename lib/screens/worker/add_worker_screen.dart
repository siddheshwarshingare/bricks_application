import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/worker_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddWorkerScreen extends StatefulWidget {
  final FactoryModel factory;
  final WorkerModel? worker;

  const AddWorkerScreen({super.key, required this.factory, this.worker});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();

  final WorkerRepository repository = WorkerRepository();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final salaryController = TextEditingController();

  String workType = "Moulding";

  bool isActive = true;

  DateTime joiningDate = DateTime.now();

  final List<String> workTypes = [
    "Moulding",
    "Loading",
    "Unloading",
    "Burning",
    "Supervisor",
    "Manager",
    "Helper",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.worker != null) {
      final worker = widget.worker!;

      nameController.text = worker.name;
      mobileController.text = worker.mobile;
      addressController.text = worker.address;
      salaryController.text = worker.salary.toString();
      workType = worker.workType;
      isActive = worker.isActive;
      joiningDate = worker.joiningDate.toDate();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  Future<void> saveWorker() async {
    if (!_formKey.currentState!.validate()) return;

    final worker = WorkerModel(
      id: widget.worker?.id ?? "",
      factoryId: widget.factory.id,
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      address: addressController.text.trim(),
      salary: double.parse(salaryController.text),
      workType: workType,
      isActive: isActive,
      joiningDate: Timestamp.fromDate(joiningDate),
      createdAt: widget.worker?.createdAt ?? Timestamp.now(),
    );

    if (widget.worker == null) {
      print("Factory ID: ${widget.factory.id}");
      print("Worker Factory ID: ${worker.factoryId}");
      await repository.addWorker(worker);
    } else {
      await repository.updateWorker(worker);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.worker == null
              ? "Worker Added Successfully"
              : "Worker Updated Successfully",
        ),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> selectJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: joiningDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        joiningDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.worker == null ? "Add Worker" : "Edit Worker",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),

        backgroundColor: const Color(0xff2563EB),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Worker Name",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter worker name";
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.length != 10) {
                  return "Enter valid mobile number";
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monthly Salary",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter salary";
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: workType,
              decoration: const InputDecoration(
                labelText: "Work Type",
                border: OutlineInputBorder(),
              ),
              items: workTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  workType = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: const Text("Joining Date"),
              subtitle: Text(
                "${joiningDate.day}/${joiningDate.month}/${joiningDate.year}",
              ),
              trailing: ElevatedButton(
                onPressed: selectJoiningDate,
                child: const Text("Select"),
              ),
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              title: const Text("Active Worker"),
              value: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: saveWorker,
                child: Text(
                  widget.worker == null ? "Save Worker" : "Update Worker",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/worker_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddTemporaryWorkerScreen extends StatefulWidget {
  final FactoryModel factory;

  const AddTemporaryWorkerScreen({super.key, required this.factory});

  @override
  State<AddTemporaryWorkerScreen> createState() =>
      _AddTemporaryWorkerScreenState();
}

class _AddTemporaryWorkerScreenState extends State<AddTemporaryWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkerRepository repository = WorkerRepository();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final dailyWageController = TextEditingController();

  String workType = 'Moulding';
  bool isActive = true;
  bool isSaving = false;

  DateTime joiningDate = DateTime.now();

  final List<String> workTypes = [
    'Moulding',
    'Loading',
    'Unloading',
    'Burning',
    'Supervisor',
    'Manager',
    'Helper',
  ];

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    dailyWageController.dispose();
    super.dispose();
  }

  Future<void> selectJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: joiningDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => joiningDate = picked);
    }
  }

  Future<void> saveWorker() async {
    if (!_formKey.currentState!.validate()) return;

    final dailyWage = double.tryParse(dailyWageController.text.trim());

    if (dailyWage == null || dailyWage <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid daily wage')));
      return;
    }

    setState(() => isSaving = true);

    try {
      final worker = WorkerModel(
        id: '',
        factoryId: widget.factory.id,
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        address: addressController.text.trim(),
        salary: 0,
        workType: workType,
        isActive: isActive,
        joiningDate: Timestamp.fromDate(joiningDate),
        createdAt: Timestamp.now(),
        workerType: 'temporary',
        paymentType: 'daily',
        dailyWage: dailyWage,
      );

      await repository.addWorker(worker);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Temporary Worker Added Successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add worker: $e')));
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Temporary Worker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Worker Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter worker name';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (value) {
                if (value == null ||
                    !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                  return 'Enter valid 10-digit mobile number';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: dailyWageController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Daily Wage',
                prefixIcon: Icon(Icons.currency_rupee),
                helperText: 'Amount payable for one full working day',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');

                if (amount == null || amount <= 0) {
                  return 'Enter a valid daily wage';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: workType,
              decoration: const InputDecoration(
                labelText: 'Work Type',
                border: OutlineInputBorder(),
              ),
              items: workTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => workType = value);
                }
              },
            ),

            const SizedBox(height: 15),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month),
              title: const Text('Joining Date'),
              subtitle: Text(
                '${joiningDate.day}/${joiningDate.month}/${joiningDate.year}',
              ),
              trailing: ElevatedButton(
                onPressed: selectJoiningDate,
                child: const Text('Select'),
              ),
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active Worker'),
              value: isActive,
              onChanged: (value) {
                setState(() => isActive = value);
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveWorker,
                icon: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isSaving ? 'Saving...' : 'Save Temporary Worker'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/factory_model.dart';
import '../../repositories/factory_repository.dart';

class AddFactoryScreen extends StatefulWidget {
  final FactoryModel? factory;
  const AddFactoryScreen({super.key, this.factory});

  @override
  State<AddFactoryScreen> createState() => _AddFactoryScreenState();
}

class _AddFactoryScreenState extends State<AddFactoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    ownerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (widget.factory != null) {
      nameController.text = widget.factory!.name;
      locationController.text = widget.factory!.location;
      ownerController.text = widget.factory!.owner;
    }
  }

  Future<void> saveFactory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    final factory = FactoryModel(
      id: widget.factory?.id ?? '',
      name: nameController.text.trim(),
      location: locationController.text.trim(),
      owner: ownerController.text.trim(),
      createdAt: widget.factory?.createdAt ?? Timestamp.now(),
    );

    if (widget.factory == null) {
      await FactoryRepository().addFactory(factory);
    } else {
      await FactoryRepository().updateFactory(factory);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xff2563EB),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.factory == null ? "Add Factory" : "Edit Factory",
          style: const TextStyle(
            fontFamily: "Poppins",
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(fontFamily: "Poppins", fontSize: 16),
                // decoration: const InputDecoration(
                //   labelText: "Factory Name",
                //   border: OutlineInputBorder(),
                //   prefixIcon: Icon(Icons.factory),
                // ),
                decoration: InputDecoration(
                  labelText: "Factory Name",
                  labelStyle: const TextStyle(fontFamily: "Poppins"),
                  prefixIcon: const Icon(
                    Icons.factory_outlined,
                    color: Color(0xff2563EB),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
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
                    borderSide: const BorderSide(
                      color: Color(0xff2563EB),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter factory name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: locationController,
                style: const TextStyle(fontFamily: "Poppins", fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Location",
                  labelStyle: const TextStyle(fontFamily: "Poppins"),
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xff2563EB),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xff2563EB),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter location";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16), const SizedBox(height: 18),

              /// Owner
              TextFormField(
                controller: ownerController,
                style: const TextStyle(fontFamily: "Poppins", fontSize: 16),
                decoration: InputDecoration(
                  labelText: "Owner Name",
                  labelStyle: const TextStyle(fontFamily: "Poppins"),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xff2563EB),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xff2563EB),
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter owner name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 35),

              // TextFormField(
              //   controller: ownerController,
              //   decoration: const InputDecoration(
              //     labelText: "Owner Name",
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.person),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.trim().isEmpty) {
              //       return "Enter owner name";
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveFactory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.factory == null
                              ? "Save Factory"
                              : "Update Factory",
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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

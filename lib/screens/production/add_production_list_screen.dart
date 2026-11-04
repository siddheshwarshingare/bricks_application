import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/production_model.dart';
import 'package:bricks_application/models/product_model.dart';
import 'package:bricks_application/models/worker_model.dart';

import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/repositories/product_repository.dart';
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
  String? selectedProductId;

  final ProductionRepository productionRepository = ProductionRepository();

  final ProductRepository productRepository = ProductRepository();

  final WorkerRepository workerRepository = WorkerRepository();

  ProductModel? selectedProduct;
  WorkerModel? selectedWorker;

  final TextEditingController bricksController = TextEditingController();

  final TextEditingController remarksController = TextEditingController();

  final TextEditingController rateController = TextEditingController();

  final TextEditingController salaryController = TextEditingController();

  final TextEditingController cashReturnedController = TextEditingController();

  final TextEditingController salaryPaidController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  bool loadingExistingData = false;
  bool saving = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    // saveProduct();
    final production = widget.production;

    if (production != null) {
      bricksController.text = production.bricksProduced.toString();

      remarksController.text = production.remarks;

      rateController.text = production.ratePer1000.toStringAsFixed(2);

      salaryController.text = production.salaryEarned.toStringAsFixed(2);

      salaryPaidController.text = production.salaryPaid.toStringAsFixed(2);

      cashReturnedController.text = production.cashReturned.toStringAsFixed(2);

      selectedDate = production.productionDate.toDate();

      loadExistingData();
    }
  }

  // ============================================================
  // LOAD EXISTING PRODUCT + WORKER
  // ============================================================
  // Future<void> saveProduct() async {
  //   final product = ProductModel(
  //     id: "",
  //     factoryId: widget.factory.id,
  //     name: "Brick",
  //     size: "6 Inch",
  //     active: true,
  //     unit: '',
  //     sellingPrice: 8,
  //     productionCost: 4,
  //     minimumStock: 5000,
  //     createdAt: Timestamp.now(),
  //   );

  //   await productRepository.addProduct(product);
  // }

  Future<void> loadExistingData() async {
    final production = widget.production;

    if (production == null) {
      return;
    }

    setState(() {
      loadingExistingData = true;
    });

    try {
      final product = await productRepository.getProduct(
        widget.factory.id,
        production.productId,
      );

      final worker = await workerRepository.getWorker(
        factoryId: widget.factory.id,
        workerId: production.workerId,
      );

      if (!mounted) return;

      setState(() {
        selectedProduct = product;
        selectedProductId = product?.id;

        selectedWorker = worker;

        loadingExistingData = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingExistingData = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading production: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // SALARY CALCULATION
  // ============================================================

  void calculateSalary() {
    final int bricks = int.tryParse(bricksController.text.trim()) ?? 0;

    final double rate = double.tryParse(rateController.text.trim()) ?? 0;

    final double salary = (bricks / 1000) * rate;

    salaryController.text = salary.toStringAsFixed(2);
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

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

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2050),
    );

    if (date == null) return;

    setState(() {
      selectedDate = date;
    });
  }

  // ============================================================
  // SAVE PRODUCTION
  // ============================================================

  Future<void> saveProduction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedProduct == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a product")));

      return;
    }

    if (selectedWorker == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a worker")));

      return;
    }

    final int? bricks = int.tryParse(bricksController.text.trim());

    if (bricks == null || bricks <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid production quantity")),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final double rate =
          double.tryParse(rateController.text.trim()) ??
          selectedWorker!.ratePer1000;

      final double salaryEarned =
          double.tryParse(salaryController.text.trim()) ?? 0;

      final double salaryPaid =
          double.tryParse(salaryPaidController.text.trim()) ?? 0;

      final double cashReturned =
          double.tryParse(cashReturnedController.text.trim()) ?? 0;

      final ProductionModel production = ProductionModel(
        id: widget.production?.id ?? "",

        factoryId: widget.factory.id,

        productId: selectedProduct!.id,

        productName: selectedProduct!.name,

        workerId: selectedWorker!.id,

        workerName: selectedWorker!.name,

        bricksProduced: bricks,

        remarks: remarksController.text.trim(),

        productionDate: Timestamp.fromDate(selectedDate),

        createdAt: widget.production?.createdAt ?? Timestamp.now(),

        ratePer1000: rate,

        salaryPaid: salaryPaid,

        salaryEarned: salaryEarned,

        cashReturned: cashReturned,
      );

      if (widget.production == null) {
        await productionRepository.addProduction(
          production,
          productSize: selectedProduct!.size,
        );
      } else {
        await productionRepository.updateProduction(production);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.production == null
                ? "Production Added"
                : "Production Updated",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving production: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    bricksController.dispose();
    remarksController.dispose();
    rateController.dispose();
    salaryController.dispose();
    cashReturnedController.dispose();
    salaryPaidController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xff2563EB),

        iconTheme: const IconThemeData(color: Colors.white),

        title: Text(
          widget.production == null ? "Add Production" : "Edit Production",

          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: loadingExistingData
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<ProductModel>>(
              stream: productRepository.getProducts(widget.factory.id),

              builder: (context, productSnapshot) {
                // ------------------------------------------------
                // PRODUCT LOADING
                // ------------------------------------------------

                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productSnapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error loading products:\n${productSnapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                //  final List<ProductModel> products = productSnapshot.data ?? [];
                final products = productSnapshot.data ?? [];

                debugPrint("================================");
                debugPrint("PRODUCT COUNT = ${products.length}");

                for (final product in products) {
                  debugPrint(
                    "PRODUCT => id=${product.id}, name=${product.name}",
                  );
                }

                debugPrint("================================");

                // ------------------------------------------------
                // WORKERS
                // ------------------------------------------------

                return StreamBuilder<List<WorkerModel>>(
                  stream: workerRepository.getWorkers(widget.factory.id),

                  builder: (context, workerSnapshot) {
                    if (workerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (workerSnapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "Error loading workers:\n${workerSnapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final List<WorkerModel> workers = workerSnapshot.data ?? [];

                    // ------------------------------------------------
                    // MATCH PRODUCT BY ID
                    // ------------------------------------------------

                    // ProductModel? currentProduct;

                    // if (selectedProduct != null &&
                    //     products.any(
                    //       (product) => product.id == selectedProduct!.id,
                    //     )) {
                    //   currentProduct = products.firstWhere(
                    //     (product) => product.id == selectedProduct!.id,
                    //   );
                    // }

                    // ------------------------------------------------
                    // MATCH WORKER BY ID
                    // ------------------------------------------------

                    WorkerModel? currentWorker;

                    if (selectedWorker != null &&
                        workers.any(
                          (worker) => worker.id == selectedWorker!.id,
                        )) {
                      currentWorker = workers.firstWhere(
                        (worker) => worker.id == selectedWorker!.id,
                      );
                    }

                    // ------------------------------------------------
                    // FORM
                    // ------------------------------------------------

                    return Form(
                      key: _formKey,

                      child: ListView(
                        padding: const EdgeInsets.all(16),

                        children: [
                          // ==========================================
                          // PRODUCT DROPDOWN
                          // ==========================================

                          DropdownButtonFormField<String>(
                            initialValue: selectedProductId,

                            isExpanded: true,

                            decoration: appInputDecoration("Select Product"),

                            hint: const Text("Select Product"),

                            items: products.map((product) {
                              return DropdownMenuItem<String>(
                                value: product.id,
                                child: Text(
                                  product.size.isEmpty
                                      ? product.name
                                      : "${product.name} - ${product.size}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: (String? productId) {
                              if (productId == null) return;

                              final product = products.firstWhere(
                                (p) => p.id == productId,
                              );

                              setState(() {
                                selectedProductId = productId;
                                selectedProduct = product;
                              });

                              debugPrint("SELECTED PRODUCT: ${product.name}");
                              debugPrint("SELECTED PRODUCT ID: ${product.id}");
                            },

                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please select product";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // WORKER DROPDOWN
                          // ==========================================
                          // ==========================================
                          // WORKER DROPDOWN
                          // ==========================================
                          DropdownButtonFormField<WorkerModel>(
                            initialValue: currentWorker,

                            isExpanded: true,

                            decoration: appInputDecoration("Select Worker"),

                            hint: const Text("Select Worker"),

                            items: workers.map((worker) {
                              return DropdownMenuItem<WorkerModel>(
                                value: worker,
                                child: Text(
                                  worker.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),

                            onChanged: (WorkerModel? worker) {
                              if (worker == null) return;

                              debugPrint(
                                "SELECTED WORKER => ${worker.id} / ${worker.name}",
                              );

                              setState(() {
                                selectedWorker = worker;
                              });
                            },

                            validator: (value) {
                              if (value == null) {
                                return "Please select worker";
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // ==========================================
                          // BRICKS
                          // ==========================================
                          TextFormField(
                            controller: bricksController,

                            keyboardType: TextInputType.number,

                            decoration: appInputDecoration("Bricks Produced"),

                            onChanged: (_) {
                              calculateSalary();
                            },

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Enter production";
                              }

                              final int? number = int.tryParse(value.trim());

                              if (number == null || number <= 0) {
                                return "Enter valid quantity";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // RATE
                          // ==========================================
                          TextFormField(
                            controller: rateController,

                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            decoration: appInputDecoration("Rate / 1000"),

                            onChanged: (_) {
                              calculateSalary();
                            },

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Enter rate";
                              }

                              final double? rate = double.tryParse(
                                value.trim(),
                              );

                              if (rate == null || rate < 0) {
                                return "Enter valid rate";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // SALARY EARNED
                          // ==========================================
                          TextFormField(
                            controller: salaryController,

                            readOnly: true,

                            decoration: appInputDecoration("Salary Earned"),
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // CASH RETURNED
                          // ==========================================
                          TextFormField(
                            controller: cashReturnedController,

                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            decoration: appInputDecoration("Cash Returned"),

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              final double? amount = double.tryParse(
                                value.trim(),
                              );

                              if (amount == null || amount < 0) {
                                return "Enter valid amount";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // SALARY PAID
                          // ==========================================
                          TextFormField(
                            controller: salaryPaidController,

                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),

                            decoration: appInputDecoration("Salary Paid"),

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              final double? amount = double.tryParse(
                                value.trim(),
                              );

                              if (amount == null || amount < 0) {
                                return "Enter valid amount";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ==========================================
                          // REMARKS
                          // ==========================================
                          TextFormField(
                            controller: remarksController,

                            maxLines: 3,

                            decoration: appInputDecoration("Remarks"),
                          ),

                          const SizedBox(height: 15),

                          // ==========================================
                          // DATE
                          // ==========================================
                          Card(
                            color: Colors.white,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xffE5E7EB)),
                            ),

                            child: ListTile(
                              leading: const Icon(
                                Icons.calendar_month,
                                color: Color(0xff2563EB),
                              ),

                              title: const Text(
                                "Production Date",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),

                              subtitle: Text(
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                              ),

                              trailing: ElevatedButton(
                                onPressed: pickDate,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff2563EB),
                                  foregroundColor: Colors.white,
                                ),

                                child: const Text("Select"),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ==========================================
                          // SAVE BUTTON
                          // ==========================================
                          SizedBox(
                            height: 56,
                            width: double.infinity,

                            child: ElevatedButton(
                              onPressed: saving ? null : saveProduction,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2563EB),

                                disabledBackgroundColor: Colors.grey,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              child: saving
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      widget.production == null
                                          ? "Save Production"
                                          : "Update Production",

                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

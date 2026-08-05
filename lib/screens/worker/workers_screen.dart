import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/worker_repository.dart';
import 'package:bricks_application/screens/worker/add_worker_screen.dart';
import 'package:flutter/material.dart';
import 'package:bricks_application/models/factory_model.dart';

class WorkerManagementScreen extends StatefulWidget {
  final FactoryModel factory;

  const WorkerManagementScreen({super.key, required this.factory});

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen> {
  final TextEditingController searchController = TextEditingController();
  final WorkerRepository repository = WorkerRepository();
  String search = "";
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Worker Management"), centerTitle: true),

      body: Column(
        children: [
          /// Search Box
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search worker...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            search = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          /// Worker List
          Expanded(
            child: StreamBuilder<List<WorkerModel>>(
              stream: repository.getWorkers(widget.factory.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final workers = snapshot.data ?? [];

                final filteredWorkers = workers.where((worker) {
                  return worker.name.toLowerCase().contains(search) ||
                      worker.mobile.contains(search);
                }).toList();

                if (filteredWorkers.isEmpty) {
                  return const Center(child: Text("No Workers Found"));
                }

                return ListView.builder(
                  itemCount: filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = filteredWorkers[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(worker.name),
                        subtitle: Text(worker.mobile),
                        trailing: Text(
                          "₹${worker.ratePer1000.toStringAsFixed(0)}/1000",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddWorkerScreen(factory: widget.factory),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Add Worker"),
      ),
    );
  }
}

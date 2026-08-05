import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/worker_repository.dart';
import 'package:bricks_application/screens/worker/add_worker_screen.dart';
import 'package:bricks_application/screens/worker/worker_account_screen.dart';
import 'package:flutter/material.dart';

class WorkerListScreen extends StatefulWidget {
  final FactoryModel factory;

  const WorkerListScreen({super.key, required this.factory});

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  final WorkerRepository repository = WorkerRepository();

  final TextEditingController searchController = TextEditingController();

  String search = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> deleteWorker(WorkerModel worker) async {
    await repository.deleteWorker(
      factoryId: widget.factory.id,
      workerId: worker.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${worker.name} deleted successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.factory.name} Workers")),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          print("Factory ID: ${widget.factory.id}");
          print("Factory Name: ${widget.factory.name}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddWorkerScreen(factory: widget.factory),
            ),
          );
        },
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search Worker",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<WorkerModel>>(
              stream: repository.getWorkers(widget.factory.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                final workers = snapshot.data ?? [];

                final filteredWorkers = workers.where((worker) {
                  return worker.name.toLowerCase().contains(search);
                }).toList();

                if (filteredWorkers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Worker Found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = filteredWorkers[index];

                    return Dismissible(
                      key: Key(worker.id),
                      direction: DismissDirection.endToStart,

                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Worker"),
                            content: const Text(
                              "Are you sure you want to delete this worker?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text("Cancel"),
                              ),

                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );
                      },

                      onDismissed: (_) {
                        deleteWorker(worker);
                      },

                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              worker.name[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          title: Text(
                            worker.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),

                              Text("📞 ${worker.mobile}"),

                              Text("💰 ₹${worker.salary}"),

                              Text("🛠 ${worker.workType}"),
                            ],
                          ),

                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddWorkerScreen(
                                    factory: widget.factory,
                                    worker: worker,
                                  ),
                                ),
                              );
                            },
                          ),

                          onTap: () {
                            print("Worker Clicked : ${worker.name}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkerAccountScreen(
                                  factory: widget.factory,
                                  worker: worker,
                                ),
                              ),
                            );
                          },
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
    );
  }
}

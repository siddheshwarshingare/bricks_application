import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/models/worker_model.dart';
import 'package:bricks_application/repositories/worker_repository.dart';
import 'package:bricks_application/screens/worker/temporary_worker_screen.dart';
import 'package:flutter/material.dart';

class TemporaryWorkerManagementScreen extends StatefulWidget {
  final FactoryModel factory;

  const TemporaryWorkerManagementScreen({super.key, required this.factory});

  @override
  State<TemporaryWorkerManagementScreen> createState() =>
      _TemporaryWorkerManagementScreenState();
}

class _TemporaryWorkerManagementScreenState
    extends State<TemporaryWorkerManagementScreen> {
  final WorkerRepository repository = WorkerRepository();
  final TextEditingController searchController = TextEditingController();

  String search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temporary Workers'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search temporary worker...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() => search = '');
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
                setState(() => search = value.toLowerCase().trim());
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final workers = (snapshot.data ?? [])
                    .where((worker) => worker.workerType == 'temporary')
                    .where(
                      (worker) =>
                          worker.name.toLowerCase().contains(search) ||
                          worker.mobile.contains(search),
                    )
                    .toList();

                if (workers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 65,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No temporary workers found',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          worker.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${worker.mobile}\n'
                          'Daily Wage: ₹${worker.dailyWage.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Next step: open temporary worker details,
                          // attendance and payment history.
                        },
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
              builder: (_) => AddTemporaryWorkerScreen(factory: widget.factory),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Temporary Worker'),
      ),
    );
  }
}

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

  // ------------------------------------------------------------
  // STANDARD APP COLORS
  // ------------------------------------------------------------

  static const Color primaryBlue = Color(0xff2563EB);
  static const Color lightBlue = Color(0xffEFF6FF);
  static const Color backgroundColor = Color(0xffF5F7FB);
  static const Color darkText = Color(0xff111827);
  static const Color greyText = Color(0xff6B7280);
  static const Color deleteRed = Color(0xffEF4444);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // DELETE WORKER
  // ------------------------------------------------------------

  Future<void> deleteWorker(WorkerModel worker) async {
    await repository.deleteWorker(
      factoryId: widget.factory.id,
      workerId: worker.id,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${worker.name} deleted successfully"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // ADD WORKER
  // ------------------------------------------------------------

  void addWorker() {
    print("Factory ID: ${widget.factory.id}");
    print("Factory Name: ${widget.factory.name}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddWorkerScreen(factory: widget.factory),
      ),
    );
  }

  // ------------------------------------------------------------
  // EDIT WORKER
  // ------------------------------------------------------------

  void editWorker(WorkerModel worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddWorkerScreen(factory: widget.factory, worker: worker),
      ),
    );
  }

  // ------------------------------------------------------------
  // WORKER ACCOUNT
  // ------------------------------------------------------------

  void openWorkerAccount(WorkerModel worker) {
    print("Worker Clicked : ${worker.name}");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WorkerAccountScreen(factory: widget.factory, worker: worker),
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH BAR
  // ------------------------------------------------------------

  Widget buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search worker...",
          hintStyle: const TextStyle(color: greyText, fontSize: 14),

          prefixIcon: const Icon(Icons.search, color: primaryBlue),

          suffixIcon: search.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: greyText),
                  onPressed: () {
                    searchController.clear();

                    setState(() {
                      search = "";
                    });
                  },
                )
              : null,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          setState(() {
            search = value.toLowerCase().trim();
          });
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // WORKER CARD
  // ------------------------------------------------------------

  Widget buildWorkerCard(WorkerModel worker) {
    final String firstLetter = worker.name.isNotEmpty
        ? worker.name[0].toUpperCase()
        : "?";

    return Dismissible(
      key: Key(worker.id),

      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: deleteRed,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              "Delete",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              "Delete Worker",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text("Are you sure you want to delete ${worker.name}?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("Cancel", style: TextStyle(color: greyText)),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: deleteRed,
                  foregroundColor: Colors.white,
                ),
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

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            openWorkerAccount(worker);
          },

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Row(
              children: [
                // ------------------------------------------------
                // WORKER AVATAR
                // ------------------------------------------------
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Center(
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // ------------------------------------------------
                // WORKER INFORMATION
                // ------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        worker.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 7),

                      // Mobile
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 15,
                            color: greyText,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              worker.mobile,
                              style: const TextStyle(
                                fontSize: 13,
                                color: greyText,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Salary
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            size: 15,
                            color: greyText,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            "Salary: ₹${worker.salary}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: greyText,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Work Type
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline,
                            size: 15,
                            color: greyText,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              worker.workType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: greyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ------------------------------------------------
                // EDIT BUTTON
                // ------------------------------------------------
                Container(
                  width: 38,
                  height: 38,

                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: IconButton(
                    padding: EdgeInsets.zero,

                    icon: const Icon(
                      Icons.edit_outlined,
                      color: primaryBlue,
                      size: 19,
                    ),

                    onPressed: () {
                      editWorker(worker);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),

            decoration: const BoxDecoration(
              color: lightBlue,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.people_outline,
              size: 48,
              color: primaryBlue,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "No Workers Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            search.isEmpty
                ? "Add your first worker"
                : "Try another worker name",
            style: const TextStyle(color: greyText, fontSize: 14),
          ),

          const SizedBox(height: 18),

          if (search.isEmpty)
            ElevatedButton.icon(
              onPressed: addWorker,

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              icon: const Icon(Icons.person_add_outlined),

              label: const Text(
                "Add Worker",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,

        title: Text(
          "${widget.factory.name} Workers",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ADD WORKER BUTTON
      // ----------------------------------------------------------
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,

        onPressed: addWorker,

        icon: const Icon(Icons.person_add_outlined),

        label: const Text(
          "Add Worker",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: buildSearchBar(),
          ),

          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),

            child: Row(
              children: [
                const Text(
                  "Workers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),

                const Spacer(),

                StreamBuilder<List<WorkerModel>>(
                  stream: repository.getWorkers(widget.factory.id),

                  builder: (context, snapshot) {
                    final count = snapshot.data?.length ?? 0;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        "$count Workers",
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Worker List
          Expanded(
            child: StreamBuilder<List<WorkerModel>>(
              stream: repository.getWorkers(widget.factory.id),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryBlue),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: deleteRed),
                    ),
                  );
                }

                final workers = snapshot.data ?? [];

                // ----------------------------------------------
                // SEARCH FILTER
                // ----------------------------------------------

                final filteredWorkers = workers.where((worker) {
                  return worker.name.toLowerCase().contains(search);
                }).toList();

                // ----------------------------------------------
                // EMPTY
                // ----------------------------------------------

                if (filteredWorkers.isEmpty) {
                  return buildEmptyState();
                }

                // ----------------------------------------------
                // LIST
                // ----------------------------------------------

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),

                  itemCount: filteredWorkers.length,

                  itemBuilder: (context, index) {
                    final worker = filteredWorkers[index];

                    return buildWorkerCard(worker);
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

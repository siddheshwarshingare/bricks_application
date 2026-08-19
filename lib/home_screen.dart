import 'package:bricks_application/main.dart';
import 'package:bricks_application/screens/factory/factory/factory_list_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  String filter = "Today";

  final filters = ["Today", "Week", "Month", "Year"];
  final TextEditingController nameController = TextEditingController();
  final List<Widget> pages = [
    // HomeDashboardScreen(),
    FactoryListScreen(),
    ProductionScreen(),
    //  WorkersScreen(),
    // ReportsScreen(factory: ,),
    SettingsScreen(),
  ];
  final TextEditingController locationController = TextEditingController();

  final TextEditingController ownerController = TextEditingController();
  Widget _buildHomeDashboard() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 13, 149, 228),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Brick Factory",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Production Dashboard",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),

              // Production Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Bricks Production",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        DropdownButton(
                          value: filter,
                          underline: const SizedBox(),
                          items: filters
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              filter = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "1,250",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     final factory = FactoryModel(
                    //       id: '1234',
                    //       name: "nameController.text",
                    //       location: "locationController.text",
                    //       owner: "ownerController.text",
                    //       createdAt: Timestamp.now(),
                    //     );

                    //     await FactoryRepository().addFactory(factory);

                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text("Factory Added")),
                    //     );
                    //   },
                    //   child: const Text("Save"),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Stats Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _statCard("Today's Sales", "320", Colors.green),
              const SizedBox(width: 12),
              _statCard("Pending Orders", "85", Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: index == 0 ? _buildHomeDashboard() : pages[index - 1],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },
        indicatorColor: const Color(0xFF1565C0).withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.factory), label: "Factories"),
          NavigationDestination(
            icon: Icon(Icons.construction),
            label: "Production",
          ),
          NavigationDestination(icon: Icon(Icons.people), label: "Workers"),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: "Reports"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

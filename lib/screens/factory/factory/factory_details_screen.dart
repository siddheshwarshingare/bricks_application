import 'package:bricks_application/customer/customer_list_screen.dart';
import 'package:bricks_application/expense/expense_screen.dart';
import 'package:bricks_application/models/factory_model.dart';
import 'package:bricks_application/screens/materials/material_list_screen.dart';
import 'package:bricks_application/screens/production/production_list_screen.dart';
import 'package:bricks_application/screens/reports/reports_screen.dart';
import 'package:bricks_application/screens/worker/worker_list_screen.dart';
import 'package:flutter/material.dart';

class FactoryManagementScreen extends StatelessWidget {
  final FactoryModel factory;

  const FactoryManagementScreen({super.key, required this.factory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          "Factory Management",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            const SizedBox(height: 24),

            const Text(
              "Manage Factory",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xff111827),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Manage your factory operations",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 16),

            // Management Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.15,
              children: [
                _managementCard(
                  context,
                  title: "Production",
                  subtitle: "Manage production",
                  icon: Icons.factory_rounded,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductionListScreen(factory: factory),
                      ),
                    );
                  },
                ),

                _managementCard(
                  context,
                  title: "Workers",
                  subtitle: "Manage workers",
                  icon: Icons.people_alt_rounded,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerListScreen(factory: factory),
                      ),
                    );
                  },
                ),

                _managementCard(
                  context,
                  title: "Materials",
                  subtitle: "Manage inventory",
                  icon: Icons.inventory_2_rounded,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MaterialListScreen(factory: factory),
                      ),
                    );
                  },
                ),

                _managementCard(
                  context,
                  title: "Customers",
                  subtitle: "Manage customers",
                  icon: Icons.people_alt_rounded,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerListScreen(factory: factory),
                      ),
                    );
                  },
                ),

                _managementCard(
                  context,
                  title: "Reports",
                  subtitle: "View factory reports",
                  icon: Icons.bar_chart_rounded,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportsScreen(factory: factory),
                      ),
                    );
                  },
                ),

                _managementCard(
                  context,
                  title: "Settings",
                  subtitle: "Factory settings",
                  icon: Icons.settings_rounded,
                  color: Colors.teal,
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                _managementCard(
                  context,
                  title: "Expenses",
                  subtitle: "Track factory expenses",
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpenseScreen(factory: factory),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Bottom info card
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff2563EB), Color(0xff3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2563EB).withValues(alpha: .20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Factory icon
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.factory_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          // Factory information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Factory",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  factory.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Colors.white70,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        factory.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MANAGEMENT CARD
  // ------------------------------------------------------------

  Widget _managementCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: .08),
        highlightColor: color.withValues(alpha: .04),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .035),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),

                  Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Title
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111827),
                ),
              ),

              const SizedBox(height: 3),

              // Subtitle
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 10.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INFO CARD
  // ------------------------------------------------------------

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffDBEAFE)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xff2563EB).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xff2563EB),
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Factory Management",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff1E3A8A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Use the options above to manage your factory operations.",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 10.5,
                    color: Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

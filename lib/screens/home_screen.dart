import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/localization_provider.dart';
import '../utils/constants.dart';
import 'dashboard/dashboard_screen.dart';
import 'batches/batches_screen.dart';
import 'incidents/incidents_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    BatchesScreen(),
    IncidentsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = context.read<DataProvider>();
      data.loadDashboard();
      data.loadBatches();
      data.loadCategories();
      data.loadSpecies();
      data.loadIncidents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationProvider>();
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: localization.translate('navigation.dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_rounded),
              label: localization.translate('navigation.batches'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.warning_amber_rounded),
              label: localization.translate('navigation.incidents'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: localization.translate('navigation.profile'),
            ),
          ],
        ),
      ),
    );
  }
}

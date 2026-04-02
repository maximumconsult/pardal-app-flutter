import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../utils/constants.dart';
import '../providers/localization_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'batches/batches_screen.dart';
import 'incidents/incidents_screen.dart';
import 'mortalities/mortalities_screen.dart';
import 'workers/workers_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screens = [
      const DashboardScreen(),
      const BatchesScreen(),
      const IncidentsScreen(),
      const MortalitiesScreen(),
      const WorkersScreen(),
      const ProfileScreen(),
    ];
  }

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
              label: context.watch<LocalizationProvider>().translate('common.dashboard'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_rounded),
              label: context.watch<LocalizationProvider>().translate('batches.title'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.warning_amber_rounded),
              label: context.watch<LocalizationProvider>().translate('incidents.title'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.trending_down),
              label: context.watch<LocalizationProvider>().translate('common.mortality'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: context.watch<LocalizationProvider>().translate('workers.title'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: context.watch<LocalizationProvider>().translate('profile.profile'),
            ),
          ],
        ),
      ),
    );
  }
}

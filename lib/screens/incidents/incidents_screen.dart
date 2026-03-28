import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import 'add_incident_screen.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadIncidentTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationProvider>();
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(localization.translate('navigation.incidents')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DataProvider>().loadIncidents(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddIncidentScreen()),
          );
          if (result == true) {
            context.read<DataProvider>().loadIncidents();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          if (data.isLoading && data.incidents.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          if (data.incidents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(localization.translate('common.no_data'), style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => data.loadIncidents(),
                    child: Text(localization.translate('common.try_again')),
                  ),
                ],
              ),
            );
          }

          final pending = data.incidents.where((i) => i['status'] == 'pending').toList();
          final inProgress = data.incidents.where((i) => i['status'] == 'in_progress').toList();
          final resolved = data.incidents.where((i) => i['status'] == 'resolved').toList();

          return RefreshIndicator(
            color: AppConstants.primaryColor,
            onRefresh: () => data.loadIncidents(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pending.isNotEmpty) ...[
                  _SectionTitle(
                    title: localization.translate('incidents.pending'),
                    count: pending.length,
                    color: AppConstants.warningColor,
                  ),
                  const SizedBox(height: 8),
                  ...pending.map((i) => _IncidentCard(incident: i, incidentTypes: data.incidentTypes)),
                ],
                if (inProgress.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: localization.translate('incidents.in_progress'),
                    count: inProgress.length,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  ...inProgress.map((i) => _IncidentCard(incident: i, incidentTypes: data.incidentTypes)),
                ],
                if (resolved.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: localization.translate('incidents.resolved'),
                    count: resolved.length,
                    color: AppConstants.accentColor,
                  ),
                  const SizedBox(height: 8),
                  ...resolved.map((i) => _IncidentCard(incident: i, incidentTypes: data.incidentTypes)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionTitle({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryDark),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Map<String, dynamic> incident;
  final List<dynamic> incidentTypes;

  const _IncidentCard({
    required this.incident,
    required this.incidentTypes,
  });

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationProvider>();
    
    final urgency = incident['urgency'] ?? 'normal';
    final urgencyColor = urgency == 'urgent'
        ? AppConstants.errorColor
        : urgency == 'important'
            ? AppConstants.warningColor
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident['type'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      incident['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  localization.translate('incidents.$urgency'),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: urgencyColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${localization.translate('incidents.reported_by')}: ${incident['reported_by'] ?? ''}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                incident['date'] ?? '',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

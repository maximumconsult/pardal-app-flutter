import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Ocorrências'),
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
                  Text('Nenhuma ocorrência', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => data.loadIncidents(),
                    child: const Text('Actualizar'),
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
                  _SectionTitle(title: 'Pendentes', count: pending.length, color: AppConstants.warningColor),
                  const SizedBox(height: 8),
                  ...pending.map((i) => _IncidentCard(incident: i, incidentTypes: data.incidentTypes)),
                ],
                if (inProgress.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Em Progresso', count: inProgress.length, color: Colors.blue),
                  const SizedBox(height: 8),
                  ...inProgress.map((i) => _IncidentCard(incident: i, incidentTypes: data.incidentTypes)),
                ],
                if (resolved.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Resolvidas', count: resolved.length, color: AppConstants.accentColor),
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
  const _SectionTitle({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryDark)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Map<String, dynamic> incident;
  final List<dynamic> incidentTypes;
  const _IncidentCard({required this.incident, required this.incidentTypes});

  // Extrair título (primeira linha) e detalhes (resto) da descrição
  String _getTitle(String description) {
    final lines = description.split('\n');
    final firstLine = lines.first.trim();
    return firstLine.length > 60 ? '${firstLine.substring(0, 60)}...' : firstLine;
  }

  String _getDetails(String description) {
    final lines = description.split('\n');
    if (lines.length > 1) {
      return lines.skip(1).join(' ').trim();
    }
    return '';
  }

  String _translateType(String type) {
    // Procurar o nome traduzido nos tipos carregados da API
    for (final t in incidentTypes) {
      if (t['slug'] == type) return t['name'] as String;
    }
    // Fallback
    switch (type) {
      case 'equipment': return 'Equipamento';
      case 'water': return 'Água';
      case 'electricity': return 'Electricidade';
      case 'disease': return 'Doença';
      case 'predator': return 'Predador';
      case 'weather': return 'Clima';
      case 'other': return 'Outro';
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgency = incident['urgency'] ?? 'normal';
    final status = incident['status'] ?? 'pending';
    final batch = incident['batch'] as Map<String, dynamic>?;
    final reporter = incident['reporter'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: AppConstants.urgencyColor(urgency), width: 4),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppConstants.urgencyColor(urgency).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppConstants.urgencyLabel(urgency),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConstants.urgencyColor(urgency)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _translateType(incident['type'] ?? ''),
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: status == 'resolved'
                      ? AppConstants.accentColor.withOpacity(0.1)
                      : status == 'in_progress'
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  AppConstants.statusLabel(status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: status == 'resolved'
                        ? AppConstants.primaryColor
                        : status == 'in_progress'
                            ? Colors.blue
                            : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getTitle(incident['description'] ?? ''),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          if (_getDetails(incident['description'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _getDetails(incident['description'] ?? ''),
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (batch != null) ...[
                Icon(Icons.inventory_2, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(batch['name'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(width: 12),
              ],
              if (reporter != null) ...[
                Icon(Icons.person, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(reporter['name'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

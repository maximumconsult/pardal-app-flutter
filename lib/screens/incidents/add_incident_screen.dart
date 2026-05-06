import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';

class AddIncidentScreen extends StatefulWidget {
  const AddIncidentScreen({super.key});

  @override
  State<AddIncidentScreen> createState() => _AddIncidentScreenState();
}

class _AddIncidentScreenState extends State<AddIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _batchId;
  String? _type;
  String _urgency = 'normal';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadIncidentTypes();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = context.read<LocalizationProvider>();
    if (!_formKey.currentState!.validate()) return;
    if (_type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('incidents.incident_type_required')), backgroundColor: AppConstants.errorColor),
      );
      return;
    }

    final data = context.read<DataProvider>();
    final body = <String, dynamic>{
      'type': _type,
      'urgency': _urgency,
      'description': _titleCtrl.text + (_descCtrl.text.isNotEmpty ? '\n${_descCtrl.text}' : ''),
    };
    if (_batchId != null) body['batch_id'] = _batchId;

    final success = await data.storeIncident(body);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('incidents.success_message')), backgroundColor: AppConstants.successColor),
      );
      Navigator.of(context).pop(true);
    } else if (mounted && data.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data.error!), backgroundColor: AppConstants.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(loc.translate('incidents.add_incident')),
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          final activeBatches = data.batches.where((b) => b['status'] == 'active').toList();
          final incidentTypes = data.incidentTypes;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgência
                  Text(loc.translate('incidents.urgency'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _UrgencyButton(
                        label: loc.translate('incidents.normal'),
                        value: 'normal',
                        color: AppConstants.accentColor,
                        isSelected: _urgency == 'normal',
                        onTap: () => setState(() => _urgency = 'normal'),
                      ),
                      const SizedBox(width: 8),
                      _UrgencyButton(
                        label: loc.translate('incidents.important'),
                        value: 'important',
                        color: AppConstants.warningColor,
                        isSelected: _urgency == 'important',
                        onTap: () => setState(() => _urgency = 'important'),
                      ),
                      const SizedBox(width: 8),
                      _UrgencyButton(
                        label: loc.translate('incidents.urgent'),
                        value: 'urgent',
                        color: AppConstants.errorColor,
                        isSelected: _urgency == 'urgent',
                        onTap: () => setState(() => _urgency = 'urgent'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tipo (dinâmico da API)
                  Text('${loc.translate('incidents.incident_type')} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _type,
                        isExpanded: true,
                        hint: Text(loc.translate('incidents.select_type')),
                        items: incidentTypes.map<DropdownMenuItem<String>>((t) {
                          return DropdownMenuItem<String>(
                            value: t['slug'] as String,
                            child: Text(t['name'] as String),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _type = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lote associado
                  Text(loc.translate('incidents.associated_batch'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: _batchId,
                        isExpanded: true,
                        hint: Text(loc.translate('incidents.no_batch')),
                        items: [
                          DropdownMenuItem<int?>(value: null, child: Text(loc.translate('incidents.no_batch'))),
                          ...activeBatches.map((b) {
                            final species = b['species'] as Map<String, dynamic>?;
                            final emoji = species != null ? AppConstants.speciesEmoji(species['icon'] ?? '') : '🐾';
                            return DropdownMenuItem<int?>(
                              value: b['id'] as int,
                              child: Text('$emoji ${b['name']}'),
                            );
                          }),
                        ],
                        onChanged: (v) => setState(() => _batchId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(loc.translate('incidents.title_label'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: _inputDecoration(loc.translate('incidents.title_hint')),
                    validator: (v) {
                      if (v == null || v.isEmpty) return loc.translate('incidents.title_required');
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Descrição
                  Text(loc.translate('incidents.description_label'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: _inputDecoration(loc.translate('incidents.incident_description')),
                  ),
                  const SizedBox(height: 28),

                  // Botão
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: data.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: data.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(loc.translate('incidents.report_incident'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
    );
  }
}

class _UrgencyButton extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _UrgencyButton({
    required this.label,
    required this.value,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

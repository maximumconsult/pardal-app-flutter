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

  late List<Map<String, dynamic>> _urgencies;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localization = context.read<LocalizationProvider>();
    _urgencies = [
      {'value': 'normal', 'label': localization.translate('incidents.normal'), 'color': AppConstants.accentColor},
      {'value': 'important', 'label': localization.translate('incidents.important'), 'color': AppConstants.warningColor},
      {'value': 'urgent', 'label': localization.translate('incidents.urgent'), 'color': AppConstants.errorColor},
    ];
  }

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
    if (!_formKey.currentState!.validate()) return;
    if (_type == null) {
      final localization = context.read<LocalizationProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localization.translate('incidents.select_type')), backgroundColor: AppConstants.errorColor),
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
      final localization = context.read<LocalizationProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localization.translate('incidents.success_message')), backgroundColor: AppConstants.successColor),
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Consumer<LocalizationProvider>(
          builder: (_, localization, __) => Text(localization.translate('incidents.add_incident')),
        ),
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          final activeBatches = data.batches.where((b) => b['status'] == 'active').toList();
          final incidentTypes = data.incidentTypes;

          return Consumer<LocalizationProvider>(
            builder: (_, localization, __) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Urgência
                    Text(localization.translate('incidents.urgency'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: _urgencies.map((u) {
                      final isSelected = _urgency == u['value'];
                      final color = u['color'] as Color;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _urgency = u['value'] as String),
                          child: Container(
                            margin: EdgeInsets.only(right: u != _urgencies.last ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.15) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
                            ),
                            child: Center(
                              child: Text(
                                u['label'] as String,
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
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                    // Tipo (dinâmico da API)
                    Text('${localization.translate('incidents.incident_type')} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                          hint: Text(localization.translate('incidents.select_type')),
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
                    Text('${localization.translate('batches.batch')} (${localization.translate('common.optional')})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                          hint: Text(localization.translate('common.none')),
                          items: [
                            DropdownMenuItem<int?>(value: null, child: Text(localization.translate('common.none'))),
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
                    Text('${localization.translate('incidents.description')} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: _inputDecoration(localization.translate('incidents.incident_description')),
                      validator: (v) {
                        if (v == null || v.isEmpty) return localization.translate('common.required_field');
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),

                    // Descrição adicional
                    Text(localization.translate('incidents.description'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: _inputDecoration('${localization.translate('common.additional')} ${localization.translate('incidents.description')}...'),
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
                            : Text(localization.translate('incidents.add_incident'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
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

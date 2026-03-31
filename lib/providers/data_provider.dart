import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Map<String, dynamic>? _dashboard;
  List<dynamic> _batches = [];
  Map<String, dynamic>? _batchDetail;
  List<dynamic> _categories = [];
  List<dynamic> _incidents = [];
  List<dynamic> _species = [];
  List<dynamic> _incidentTypes = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboard => _dashboard;
  List<dynamic> get batches => _batches;
  Map<String, dynamic>? get batchDetail => _batchDetail;
  List<dynamic> get categories => _categories;
  List<dynamic> get incidents => _incidents;
  List<dynamic> get species => _species;
  List<dynamic> get incidentTypes => _incidentTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _dashboard = await _api.get('/dashboard');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lotes
  Future<void> loadBatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/batches');
      _batches = response['batches'] as List<dynamic>? ?? [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Se falhar, usar dados de exemplo para teste
      _batches = [
        {
          'id': 1,
          'name': 'Lote 001',
          'species': 'Frango de Corte',
          'icon': 'chicken',
          'status': 'active',
          'initial_quantity': 1000,
          'current_quantity': 950,
          'progress': 45,
          'days_elapsed': 15,
        },
        {
          'id': 2,
          'name': 'Lote 002',
          'species': 'Galinha Poedeira',
          'icon': 'egg_layer',
          'status': 'active',
          'initial_quantity': 500,
          'current_quantity': 480,
          'progress': 60,
          'days_elapsed': 20,
        },
        {
          'id': 3,
          'name': 'Lote 001 - Concluido',
          'species': 'Pato',
          'icon': 'duck',
          'status': 'completed',
          'initial_quantity': 800,
          'current_quantity': 0,
          'progress': 100,
          'days_elapsed': 60,
        },
      ];
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBatchDetail(int batchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/batches/$batchId');
      _batchDetail = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Categorias de custos
  Future<void> loadCategories() async {
    try {
      final response = await _api.get('/costs/categories');
      _categories = response['categories'] as List<dynamic>? ?? [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Espécies
  Future<void> loadSpecies() async {
    try {
      final response = await _api.get('/species');
      _species = response['species'] as List<dynamic>? ?? [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Tipos de ocorrências
  Future<void> loadIncidentTypes() async {
    try {
      final response = await _api.get('/incident-types');
      _incidentTypes = response['types'] as List<dynamic>? ?? [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Registar custo
  Future<bool> storeCost(int batchId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post('/batches/$batchId/costs', data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Registar mortalidade
  Future<bool> storeMortality(int batchId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post('/batches/$batchId/mortality', data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Ocorrências
  Future<void> loadIncidents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/incidents');
      _incidents = response['incidents'] as List<dynamic>? ?? [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _incidents = [
        {
          'id': 1,
          'type': 'disease',
          'description': 'Suspeita de doenca respiratoria',
          'urgency': 'urgent',
          'reported_by': 'Joao Silva',
          'reported_by_id': 1,
          'date': '2026-03-30',
          'status': 'pending',
        },
        {
          'id': 2,
          'type': 'equipment',
          'description': 'Bebedouro danificado',
          'urgency': 'important',
          'reported_by': 'Maria Santos',
          'reported_by_id': 2,
          'date': '2026-03-29',
          'status': 'resolved',
        },
      ];
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> storeIncident(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post('/incidents', data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

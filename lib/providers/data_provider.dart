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
  List<dynamic> _workers = [];
  List<dynamic> _mortalities = [];
  Map<String, dynamic>? _mortalitySummary;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get dashboard => _dashboard;
  List<dynamic> get batches => _batches;
  Map<String, dynamic>? get batchDetail => _batchDetail;
  List<dynamic> get categories => _categories;
  List<dynamic> get incidents => _incidents;
  List<dynamic> get species => _species;
  List<dynamic> get incidentTypes => _incidentTypes;
  List<dynamic> get workers => _workers;
  List<dynamic> get mortalities => _mortalities;
  Map<String, dynamic>? get mortalitySummary => _mortalitySummary;
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
      _error = e.toString();
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
      _error = e.toString();
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

  // Workers
  Future<void> loadWorkers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/workers');
      _workers = response['workers'] as List<dynamic>? ?? [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWorker(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.post('/workers', data);
      await loadWorkers();
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

  // Mortalities
  Future<void> loadMortalities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/mortalities');
      _mortalities = response['mortalities'] as List<dynamic>? ?? [];
      _mortalitySummary = response['summary'] as Map<String, dynamic>?;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

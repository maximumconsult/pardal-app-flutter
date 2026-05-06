import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/subscription_plan.dart';

class SubscriptionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<SubscriptionPlan> _plans = [];
  SubscriptionPlan? _currentPlan;
  String _subscriptionStatus = 'active';
  String? _expiresAt;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;
  String? _paymentUrl;
  String? _paymentId;

  List<SubscriptionPlan> get plans => _plans;
  SubscriptionPlan? get currentPlan => _currentPlan;
  String get subscriptionStatus => _subscriptionStatus;
  String? get expiresAt => _expiresAt;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get paymentUrl => _paymentUrl;
  String? get paymentId => _paymentId;

  /// Carregar todos os planos disponíveis
  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/plans');
      final plansList = response['plans'] as List<dynamic>? ?? [];
      _plans = plansList
          .map((p) => SubscriptionPlan.fromJson(p as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carregar subscrição actual
  Future<void> loadCurrentSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/subscription');
      if (response['plan'] != null) {
        _currentPlan = SubscriptionPlan.fromJson(
            response['plan'] as Map<String, dynamic>);
      }
      _subscriptionStatus = response['status'] as String? ?? 'active';
      _expiresAt = response['expires_at'] as String?;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscrever a um plano (gratuito ou pago)
  Future<bool> subscribe(int planId, {String billingCycle = 'monthly', String? paymentMethod}) async {
    _isProcessing = true;
    _error = null;
    _paymentUrl = null;
    _paymentId = null;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        'plan_id': planId,
        'billing_cycle': billingCycle,
      };
      if (paymentMethod != null) {
        body['payment_method'] = paymentMethod;
      }
      final response = await _api.post('/subscription/subscribe', body);

      if (response['success'] == true) {
        // Plano gratuito activado directamente
        if (response['plan'] != null) {
          _currentPlan = SubscriptionPlan.fromJson(
              response['plan'] as Map<String, dynamic>);
          _subscriptionStatus = 'active';
        }
        _isProcessing = false;
        notifyListeners();
        return true;
      } else if (response['payment_url'] != null) {
        // Plano pago - precisa de pagamento
        _paymentUrl = response['payment_url'] as String;
        _paymentId = response['payment_id'] as String?;
        _isProcessing = false;
        notifyListeners();
        return true;
      }

      _error = response['message'] as String? ?? 'Erro desconhecido';
      _isProcessing = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Verificar estado do pagamento
  Future<String> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _api.post('/payments/check-status', {
        'payment_id': paymentId,
      });
      final status = response['status'] as String? ?? 'pending';
      if (status == 'completed' || status == 'paid') {
        await loadCurrentSubscription();
      }
      return status;
    } catch (e) {
      return 'error';
    }
  }

  /// Verificar se o plano é um upgrade ou downgrade
  String getPlanChangeType(SubscriptionPlan targetPlan) {
    if (_currentPlan == null) return 'subscribe';
    if (targetPlan.id == _currentPlan!.id) return 'current';
    if (targetPlan.monthlyPrice > _currentPlan!.monthlyPrice) return 'upgrade';
    return 'downgrade';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearPayment() {
    _paymentUrl = null;
    _paymentId = null;
    notifyListeners();
  }
}

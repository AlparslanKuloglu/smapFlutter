import 'package:smap/domain/models/legal_document.dart';

abstract class AuthRepository {
  Future<bool> getOnboardingCompleted();
  Future<void> completeOnboarding();
  Future<bool> validateSession();
  Future<bool> login({required String username, required String password});
  Future<bool> register({required Map<String, dynamic> payload});
  Future<List<LegalDocument>> getLegalDocuments();
  Future<void> logout();
}

import 'package:flutter/foundation.dart';
import 'package:studentmap/features/auth/domain/usecases/register_usecase.dart';
import 'package:studentmap/features/auth/domain/usecases/get_legal_documents_usecase.dart';
import 'package:studentmap/domain/models/legal_document.dart';

class RegisterNotifier extends ChangeNotifier {
  RegisterNotifier({
    required RegisterUseCase registerUseCase,
    required GetLegalDocumentsUseCase getLegalDocumentsUseCase,
  }) : _registerUseCase = registerUseCase,
       _getLegalDocumentsUseCase = getLegalDocumentsUseCase,
       _state = const RegisterState.initial();

  final RegisterUseCase _registerUseCase;
  final GetLegalDocumentsUseCase _getLegalDocumentsUseCase;
  RegisterState _state;
  RegisterState get state => _state;

  List<LegalDocument> _legalDocuments = [];
  bool _isLoadingLegalDocs = false;

  List<LegalDocument> get legalDocuments => _legalDocuments;
  bool get isLoadingLegalDocs => _isLoadingLegalDocs;

  LegalDocument? getDocumentByName(String name) {
    try {
      return _legalDocuments.firstWhere((doc) => doc.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Ekran açıldığında çağrılan ve aktif metinleri çeken metot
  Future<void> fetchLegalDocuments() async {
    _isLoadingLegalDocs = true;
    notifyListeners();

    try {
      _legalDocuments = await _getLegalDocumentsUseCase();
    } catch (e) {
      debugPrint("Sözleşme metinleri yüklenirken hata oluştu: $e");
    } finally {
      _isLoadingLegalDocs = false;
      notifyListeners();
    }
  }

  /// Parametreleri tek tek almak yerine RegisterForm'daki 'payload' haritasını doğrudan alıyoruz.
  Future<void> register({required Map<String, dynamic> payload}) async {
    _updateState(const RegisterState.loading());
    try {
      final updatedPayload = Map<String, dynamic>.from(payload);

      final termsDoc = getDocumentByName('kullanim_kosullari');
      final kvkkDoc = getDocumentByName('kvkk_aydinlatma_metni');
      final privacyDoc = getDocumentByName('gizlilik_politikasi');

      if (termsDoc != null) {
        updatedPayload['acceptedTermsVersion'] = termsDoc.version;
      }
      if (kvkkDoc != null) {
        updatedPayload['acceptedKvkkVersion'] = kvkkDoc.version;
      }
      if (privacyDoc != null) {
        updatedPayload['acceptedPrivacyVersion'] = privacyDoc.version;
      }

      final isSuccess = await _registerUseCase(payload: updatedPayload);

      if (isSuccess) {
        _updateState(const RegisterState.success());
      } else {
        _updateState(
          const RegisterState.failure(
            'Hata: Kayıt işlemi gerçekleştirilemedi.',
          ),
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint("errorMessage: $errorMessage");
      _updateState(RegisterState.failure(errorMessage));
    }
  }

  void _updateState(RegisterState newState) {
    _state = newState;
    notifyListeners();
  }
}

class RegisterState {
  const RegisterState._({
    required this.isLoading,
    required this.isSuccess,
    this.errorMessage,
  });

  const RegisterState.initial() : this._(isLoading: false, isSuccess: false);
  const RegisterState.loading() : this._(isLoading: true, isSuccess: false);
  const RegisterState.success() : this._(isLoading: false, isSuccess: true);
  const RegisterState.failure(String message)
    : this._(isLoading: false, isSuccess: false, errorMessage: message);

  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
}

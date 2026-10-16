import 'package:studentmap/features/auth/domain/repositories/auth_repository.dart';
import 'package:studentmap/domain/models/legal_document.dart';

class GetLegalDocumentsUseCase {
  final AuthRepository _repository;

  GetLegalDocumentsUseCase(this._repository);

  Future<List<LegalDocument>> call() async {
    return await _repository.getLegalDocuments();
  }
}

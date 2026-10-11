import 'package:flutter/foundation.dart';

import 'package:smap/features/account/data/dtos/legal_document_dto.dart';

/// The legal texts the sign-up form needs (pano 2.5 "Kullanım Koşulları" and
/// "KVKK Aydınlatma Metni", pano 2.6 kare 3).
///
/// The form offers the checkbox only when both texts of the consent line can
/// be read: without them no consent can be recorded and "Kayıt Ol" stays
/// closed (PLAN 0.5; decision 1.3 "Gelmezse onay satırı hata kutusuna döner").
/// The privacy policy is recorded with the others when the server has it; the
/// consent line does not name it.
@immutable
class RegisterLegalTexts {
  const RegisterLegalTexts({
    required this.terms,
    required this.kvkk,
    this.privacy,
  });

  /// The machine names of `GET /ajax/getLegalDocuments`.
  static const String termsName = 'kullanim_kosullari';
  static const String kvkkName = 'kvkk_aydinlatma_metni';
  static const String privacyName = 'gizlilik_politikasi';

  final LegalDocumentDto terms;
  final LegalDocumentDto kvkk;
  final LegalDocumentDto? privacy;

  /// Picks the texts out of the server's list; `null` when the terms or the
  /// KVKK notice are missing, retired (`isActive: false`) or have no text.
  /// Of several documents with one name the first active one wins.
  static RegisterLegalTexts? pick(List<LegalDocumentDto> documents) {
    LegalDocumentDto? find(String name, {bool needsText = true}) {
      for (final document in documents) {
        if (document.name != name || !document.active) continue;
        if (needsText && (document.content?.trim().isEmpty ?? true)) continue;
        return document;
      }
      return null;
    }

    final terms = find(termsName);
    final kvkk = find(kvkkName);
    if (terms == null || kvkk == null) return null;
    return RegisterLegalTexts(
      terms: terms,
      kvkk: kvkk,
      privacy: find(privacyName, needsText: false),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RegisterLegalTexts &&
      other.terms.id == terms.id &&
      other.terms.version == terms.version &&
      other.kvkk.id == kvkk.id &&
      other.kvkk.version == kvkk.version &&
      other.privacy?.version == privacy?.version;

  @override
  int get hashCode => Object.hash(
    terms.id,
    terms.version,
    kvkk.id,
    kvkk.version,
    privacy?.version,
  );
}

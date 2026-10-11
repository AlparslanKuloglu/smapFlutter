import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';

part 'generated/legal_document_dto.mapper.dart';

/// One legal text of `GET /ajax/getLegalDocuments` (KVKK notice, terms of use,
/// privacy policy).
///
/// Fields follow the legacy `LegalDocument` model: `_id`, `name`, `title`,
/// `version`, `content`, `isActive`. Every field is optional here; nothing is
/// filled with a made-up default. The registration flow records the accepted
/// version by [name] (`accepted*Version` in the register body).
///
/// The design also wants a date per document (spec §6.3 #13); the backend
/// sends none that the legacy code reads, so there is no date field.
@MappableClass(ignoreNull: true)
class LegalDocumentDto with LegalDocumentDtoMappable {
  const LegalDocumentDto({
    this.id,
    this.name,
    this.title,
    this.version,
    this.content,
    this.isActive,
  });

  factory LegalDocumentDto.fromJson(Map<String, dynamic> json) =>
      LegalDocumentDtoMapper.fromJson(json);

  /// Mongo `_id`.
  @MappableField(key: '_id', hook: TextOrNullHook())
  final String? id;

  /// Machine name: `kvkk_aydinlatma_metni`, `kullanim_kosullari`,
  /// `gizlilik_politikasi`.
  @MappableField(hook: TextOrNullHook())
  final String? name;

  /// Heading to show.
  @MappableField(hook: TextOrNullHook())
  final String? title;

  /// Version text such as `1.0.0`.
  @MappableField(hook: TextOrNullHook())
  final String? version;

  /// The text, plain or HTML (the legacy screen renders it with
  /// `flutter_html`).
  @MappableField(hook: TextOrNullHook())
  final String? content;

  @MappableField(hook: BoolOrNullHook())
  final bool? isActive;

  /// The legacy model counted a document without the flag as active; so does
  /// this, and only an explicit `false` retires one.
  bool get active => isActive != false;
}

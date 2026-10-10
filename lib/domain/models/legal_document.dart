class LegalDocument {
  final String id;
  final String
  name; // 'kvkk_aydinlatma_metni', 'kullanim_kosullari', 'gizlilik_politikasi'
  final String title;
  final String version;
  final String content;
  final bool isActive;

  LegalDocument({
    required this.id,
    required this.name,
    required this.title,
    required this.version,
    required this.content,
    required this.isActive,
  });

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      version: json['version'] ?? '1.0.0',
      content: json['content'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}

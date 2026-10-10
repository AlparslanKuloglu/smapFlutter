enum ExamType {
  tyt('Temel Yeterlilik Testi', 1), // Buradaki değerler .value ve .id olacak
  ayt('Alan Yeterlilik Testi', 2),
  yks('Yükseköğretim Kurumları Sınavı', 3);

  // Değişkenleri tanımla
  final String label;
  final int value;

  // Constructor ekle
  const ExamType(this.label, this.value);
}

class AnalyticsLesson {
  final String id;
  final String name;

  const AnalyticsLesson({required this.id, required this.name});
}

enum AytGroup {
  esitAgirlik('Eşit Ağırlık', 2), // Buradaki değerler .value ve .id olacak
  sayisal('Sayısal', 3),
  sozel('Sözel', 4);

  // Değişkenleri tanımla
  final String label;
  final int value;

  // Constructor ekle
  const AytGroup(this.label, this.value);
}

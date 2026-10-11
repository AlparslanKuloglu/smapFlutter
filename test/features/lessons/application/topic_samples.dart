import 'package:smap/features/lessons/domain/lesson_content.dart';

/// "Sözcükte Anlam" as pano 7.3 draws it: the first sub-topic has four items
/// and the first one is missing (Ek C).
List<SubSubject> sozcukteAnlam() => [
  SubSubject(
    id: 'ss-1',
    name: 'Anlamı Yönünden Sözcükler',
    items: [
      const LessonItem(
        id: 'i-1',
        name: 'Temel Anlam',
        descriptions: [
          'Bir sözcüğün akla gelen ilk anlamıdır. Sözlük anlamı da denir.',
          'Örnek: Bazı insanlar karanlıktan korkar. (Cümledeki karanlık, '
              'ışıksız anlamında kullanılmıştır.)',
        ],
        progress: ItemProgress(id: 'p-1', status: 0, statusArray: [0]),
      ),
      const LessonItem(
        id: 'i-2',
        name: 'Yan Anlam',
        descriptions: [
          'Bir sözcüğün temel anlamıyla bağlantılı olarak kazandığı yeni '
              'anlamdır.',
          'Örnek: Yorganın yüzü kirlenmiş.',
        ],
        progress: ItemProgress(id: 'p-2', status: 1, statusArray: [1]),
      ),
      const LessonItem(id: 'i-3', name: 'Mecaz Anlam'),
      const LessonItem(
        id: 'i-4',
        name: 'Terim Anlam',
        isFavorite: true,
        progress: ItemProgress(id: 'p-4'),
      ),
    ],
  ),
  const SubSubject(
    id: 'ss-2',
    name: 'Sözcükler Arası Anlam İlişkileri',
    items: [
      LessonItem(
        id: 'i-5',
        name: 'Eş Anlam',
        progress: ItemProgress(id: 'p-5', status: 0, statusArray: [1, 0]),
      ),
    ],
  ),
  const SubSubject(id: 'ss-3', name: 'Mecaz Oluşturma Yolları'),
];

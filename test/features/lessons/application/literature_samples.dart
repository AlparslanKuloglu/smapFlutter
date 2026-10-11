import '../../../core/network/fake_adapter.dart';

/// Namık Kemal with the works of pano 7.4 kare 2; the first Tiyatro work is
/// missing and the Romans are learned.
Map<String, Object?> namikKemal() => {
  '_id': 'au-nk',
  'name': 'Namık Kemal',
  'desc': [
    'Tanzimat Dönemi\'nin şair ve yazarı; "vatan şairi" olarak bilinir.',
    'Edebiyatı toplumu eğitmenin aracı olarak gördü.',
  ],
  'image': '/authors/a/namikkemal.png',
  'itsYazar': 1,
  'yazarCategory': 'era-tanzimat',
  'works': [
    _work('İntibah', '2', 'w-1', learned: true),
    _work('Cezmi', '2', 'w-2', learned: true),
    _work('Vatan yahut Silistre', '6', 'w-3'),
    _work('Gülnihal', '6', 'w-4'),
    {'eser': 'Bilinmeyen', 'type': '99'},
  ],
};

Map<String, Object?> _work(
  String title,
  String type,
  String progressId, {
  bool learned = false,
}) => {
  'eser': title,
  'type': type,
  'itemData': {
    '_id': progressId,
    'status': learned ? 1 : 0,
    'statusArray': [learned ? 1 : 0],
  },
};

Map<String, Object?> author(String name, String era) => {
  '_id': 'au-$name',
  'name': name,
  'itsYazar': 1,
  'yazarCategory': era,
  'works': <Object>[],
};

/// The Yazar ve Eserler tree of the curriculum with three eras.
class LiteratureBackend {
  LiteratureBackend({this.failEra});

  /// An era id whose authors fail to load.
  final String? failEra;

  final List<String> authorCalls = [];
  int maxParallel = 0;
  int _running = 0;

  late final FakeAdapter adapter = FakeAdapter((options) async {
    switch (options.path) {
      case '/student/yazarEserMainSubjects':
        return jsonResponse({
          'success': true,
          'mainSubjects': [
            {'_id': 'm-1', 'name': 'Edebi Dönemler'},
          ],
        });
      case '/student/getSubSubjects':
        return jsonResponse({
          'success': true,
          'subSubjects': [
            {'_id': 'ss-1', 'name': 'Batı Etkisinde Gelişen Edebiyat'},
          ],
        });
      case '/student/getItems':
        return jsonResponse({
          'success': true,
          'itemsArray': [
            [
              {'_id': 'era-tanzimat', 'name': 'Tanzimat'},
              {'_id': 'era-servet', 'name': 'Servet-i Fünun'},
              {'_id': 'era-milli', 'name': 'Millî Edebiyat Dönemi'},
            ],
          ],
        });
      case '/student/getSubjectAuthors':
        final era = options.queryParameters['itemId'] as String;
        authorCalls.add(era);
        _running++;
        if (_running > maxParallel) maxParallel = _running;
        await Future<void>.delayed(const Duration(milliseconds: 5));
        _running--;
        if (era == failEra) {
          return jsonResponse({'success': false}, status: 500);
        }
        return jsonResponse({
          'success': true,
          'authors': switch (era) {
            'era-tanzimat' => [
              namikKemal(),
              author('Şinasi', era),
              author('Ziya Paşa', era),
            ],
            'era-servet' => [
              author('Tevfik Fikret', era),
              author('Halit Ziya Uşaklıgil', era),
            ],
            _ => [author('Mehmet Akif Ersoy', era)],
          },
        });
    }
    return jsonResponse({'error': 'no route'}, status: 404);
  });
}

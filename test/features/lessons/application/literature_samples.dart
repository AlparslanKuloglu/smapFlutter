import 'dart:async';

import 'package:dio/dio.dart' show RequestOptions, ResponseBody;

import '../../../core/network/fake_adapter.dart';

/// Namık Kemal with the works of pano 14.6 kare 1: eight works, "İntibah" and
/// "Vatan yahut Silistre" missing, the rest known.
Map<String, Object?> namikKemal() => {
  '_id': 'au-nk',
  'name': 'Namık Kemal',
  'desc': [
    'Tanzimat Dönemi\'nin şair ve yazarı; "vatan şairi" olarak bilinir. '
        'Edebiyatı toplumu eğitmenin aracı olarak gördü.',
    'Vatan yahut Silistre oyunu sahnelendiğinde büyük ilgi gördü.',
  ],
  'image': '/authors/a/namikkemal.png',
  'itsYazar': 1,
  'yazarCategory': 'grp-1',
  'works': [
    work('İntibah', '2', 'w-1', status: 0),
    work('Cezmi', '2', 'w-2', status: 1),
    work('Vatan yahut Silistre', '6', 'w-3', status: 0),
    work('Gülnihal', '6', 'w-4', status: 1),
    work('Akif Bey', '6', 'w-5', status: 1),
    work('Zavallı Çocuk', '6', 'w-6', status: 1),
    work('Kara Bela', '6', 'w-7', status: 1),
    work('Celaleddin Harzemşah', '6', 'w-8', status: 1),
  ],
};

/// Şinasi, pano 14.6 kare 3: one known work, one with no status and one of a
/// type outside the table.
Map<String, Object?> sinasi() => {
  '_id': 'au-s',
  'name': 'Şinasi',
  'desc': ['Tanzimat edebiyatının öncüsü.'],
  'image': '/authors/a/author.png',
  'itsYazar': 1,
  'yazarCategory': 'grp-1',
  'works': [
    work('Şair Evlenmesi', '6', 'w-9', status: 1),
    work('Müntehabat-ı Eş\'ar', '1', null),
    work('Tercüme-i Manzume', '99', null),
  ],
};

/// Ziya Paşa: six works, none with a status.
Map<String, Object?> ziyaPasa() => {
  '_id': 'au-zp',
  'name': 'Ziya Paşa',
  'itsYazar': 1,
  'yazarCategory': 'grp-1',
  'works': [for (var i = 1; i <= 6; i++) work('Eser $i', '1', null)],
};

Map<String, Object?> authorWithoutWorks(String name, String group) => {
  '_id': 'au-$name',
  'name': name,
  'itsYazar': 1,
  'yazarCategory': group,
  'works': <Object>[],
};

/// A work of `works[]`; [progressId] null leaves `itemData` out (no status).
Map<String, Object?> work(
  String title,
  String type,
  String? progressId, {
  int? status,
}) => {
  'eser': title,
  'type': type,
  'itemData': ?(progressId == null
      ? null
      : {
          '_id': progressId,
          'status': ?status,
          'statusArray': ?(status == null ? null : [status]),
        }),
};

/// The Yazar ve Eserler tree of pano 14.5 over the real paths:
/// five eras (Tanzimat Dönemi 2 missing, Servet-i Fünun Dönemi 1), the two
/// sub-subjects of Tanzimat Dönemi and the authors under each.
class LiteratureServer {
  /// Eras whose `getSubSubjects` fails.
  final Set<String> failSubsOf = {};

  /// Group ids (`getSubjectAuthors?itemId=`) that fail.
  final Set<String> failGroups = {};

  /// Moves the missing count of Tanzimat Dönemi from its first sub-subject
  /// to its second.
  bool missingInSecondSub = false;

  /// Leaves every sub-subject without a count.
  bool noSubCounts = false;

  bool failEras = false;
  bool failLearn = false;
  bool emptyEras = false;

  /// While set, `getSubjectAuthors` waits for it.
  Completer<void>? authorsGate;

  /// Every request path with its query, in order.
  final List<String> asked = [];

  /// The progress ids `learnedItem` was called with.
  final List<String> learned = [];

  int count(String path) => asked.where((a) => a.startsWith(path)).length;

  /// Whether the request belongs to the tree: the other lesson tests share
  /// the adapter and use their own ids on `getSubSubjects`, `getItems` and
  /// `learnedItem`.
  static bool owns(RequestOptions options) {
    final query = options.queryParameters;
    return switch (options.path) {
      '/student/yazarEserMainSubjects' || '/student/getSubjectAuthors' => true,
      '/student/getSubSubjects' => '${query['mainSubjectId']}'.startsWith('m-'),
      '/student/getItems' => query['yazarEserMode'] == 'true',
      '/student/learnedItem' => '${query['itemId']}'.startsWith('w-'),
      _ => false,
    };
  }

  /// Answers a request of the tree, `null` for any other.
  Future<ResponseBody?> handle(RequestOptions options) async {
    if (!owns(options)) return null;
    final query = options.queryParameters;
    switch (options.path) {
      case '/student/yazarEserMainSubjects':
        asked.add(options.path);
        if (failEras) return _failure();
        return jsonResponse({
          'success': true,
          'mainSubjects': emptyEras
              ? <Object>[]
              : [
                  {
                    '_id': 'm-tanzimat',
                    'name': 'Tanzimat Dönemi',
                    'order': 1,
                    'itemDataCount': 2,
                  },
                  {
                    '_id': 'm-servet',
                    'name': 'Servet-i Fünun Dönemi',
                    'order': 2,
                    'itemDataCount': 1,
                  },
                  {'_id': 'm-fecr', 'name': 'Fecr-i Âti', 'order': 3},
                  {
                    '_id': 'm-milli',
                    'name': 'Millî Edebiyat Dönemi',
                    'order': 4,
                  },
                  {
                    '_id': 'm-cumhuriyet',
                    'name': 'Cumhuriyet Dönemi',
                    'order': 5,
                  },
                ],
        });
      case '/student/getSubSubjects':
        final era = query['mainSubjectId'] as String;
        asked.add('${options.path}?mainSubjectId=$era');
        if (failSubsOf.contains(era)) return _failure();
        return jsonResponse({
          'success': true,
          'subSubjects': switch (era) {
            'm-tanzimat' => [
              {
                '_id': 'ss-1',
                'name': 'Birinci Dönem Sanatçıları',
                if (!noSubCounts && !missingInSecondSub) 'itemDataCount': 2,
              },
              {
                '_id': 'ss-2',
                'name': 'İkinci Dönem Sanatçıları',
                if (!noSubCounts && missingInSecondSub) 'itemDataCount': 2,
              },
            ],
            'm-servet' => [
              {
                '_id': 'ss-3',
                'name': 'Edebiyat-ı Cedide Sanatçıları',
                'itemDataCount': 1,
              },
            ],
            _ => <Object>[],
          },
        });
      case '/student/getItems':
        asked.add(
          '${options.path}?edebiyat=${query['edebiyat']}'
          '&yazarEserMode=${query['yazarEserMode']}',
        );
        final ids = (options.data as Map)['subjectIds'] as List;
        return jsonResponse({
          'success': true,
          'itemsArray': [
            for (final id in ids)
              switch (id) {
                'ss-1' => [
                  {'_id': 'grp-1', 'name': 'Birinci Dönem Sanatçıları'},
                ],
                'ss-2' => [
                  {'_id': 'grp-2', 'name': 'İkinci Dönem Sanatçıları'},
                ],
                'ss-3' => [
                  {'_id': 'grp-3', 'name': 'Edebiyat-ı Cedide'},
                ],
                _ => <Object>[],
              },
          ],
        });
      case '/student/getSubjectAuthors':
        final group = query['itemId'] as String;
        asked.add('${options.path}?itemId=$group');
        final gate = authorsGate;
        if (gate != null) await gate.future;
        if (failGroups.contains(group)) return _failure();
        return jsonResponse({
          'success': true,
          'authors': switch (group) {
            'grp-1' => [namikKemal(), sinasi(), ziyaPasa()],
            'grp-2' => [
              authorWithoutWorks('Recaizade Mahmut Ekrem', group),
              authorWithoutWorks('Abdülhak Hamit Tarhan', group),
              authorWithoutWorks('Sami Paşazade Sezai', group),
            ],
            'grp-3' => [
              {
                '_id': 'au-tf',
                'name': 'Tevfik Fikret',
                'itsYazar': 1,
                'yazarCategory': group,
                'works': [work('Rübab-ı Şikeste', '1', 'w-20', status: 0)],
              },
            ],
            _ => <Object>[],
          },
        });
      case '/student/learnedItem':
        final id = query['itemId'] as String;
        asked.add('${options.path}?itemId=$id');
        if (failLearn) return _failure();
        learned.add(id);
        return jsonResponse({'success': true});
    }
    return null;
  }

  ResponseBody _failure() => jsonResponse({'success': false}, status: 500);
}

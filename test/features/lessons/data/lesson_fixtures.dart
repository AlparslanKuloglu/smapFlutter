const tarihId = '69d3ccc2fdfe9f2106fa471f';
const turkceId = '69d3c972fdfe9f2106fa471e';
const matematikId = '69d3ccf8fdfe9f2106fa4722';

/// `getGeneralLessons` as the legacy reader sees it (no `success` flag).
Map<String, Object?> generalLessonsAnswer() => {
  'generalLessons': [
    {
      '_id': tarihId,
      'name': 'Tarih',
      'image': '/icons/historybook2.png',
      'order': 2,
      'tytAyt': 1,
      'mindMap': 0,
    },
    {
      '_id': turkceId,
      'name': 'Türkçe',
      'image': '/icons/open-book.png',
      'order': 1,
      'tytAyt': 0,
      'mindMap': 0,
    },
    {
      '_id': matematikId,
      'name': 'Matematik',
      'order': '5',
      'tytAyt': 0,
      'mindMap': 1,
    },
  ],
};

/// `getLessonsTotalMissing`: counts per track under `lessonObj`.
Map<String, Object?> lessonsMissingAnswer() => {
  'success': true,
  'lessonObj': {
    tarihId: {'1': 3, '2': '5', '3': 0},
    turkceId: {'1': 12},
  },
};

/// `mainSubjects` of TYT Tarih.
Map<String, Object?> mainSubjectsAnswer() => {
  'success': true,
  'lesson': {'type': 1},
  'filterObjs': [
    {'name': 'TYT', 'value': 1, 'filter': <String, Object?>{}},
    {'name': 'AYT', 'value': 3, 'filter': <String, Object?>{}},
    {'name': 'SOS-2', 'value': 4},
  ],
  'subjects': [
    {
      '_id': 'sub-1',
      'name': 'İslamiyet Öncesi Türk Tarihi',
      'order': 1,
      'image': 'turk.png',
      'imageColor': '#ffeed6',
      'barColor': '#eaa353',
    },
    {'_id': 'sub-2', 'name': 'Osmanlı Tarihi', 'order': '2'},
    {'name': 'no id'},
  ],
  'resultByType': {
    '1': {'sub-1': 3, 'sub-2': 1},
    '3': {'sub-1': '2'},
    '4': <String, Object?>{},
  },
};

/// `getSubSubjects`.
Map<String, Object?> subSubjectsAnswer() => {
  'success': true,
  'subSubjects': [
    {'_id': 'ss-1', 'name': 'Türklerin ilk yurdu'},
    {'_id': 'ss-2', 'name': 'Kurumlar'},
    {'name': 'no id'},
  ],
};

/// `getItems`: one list per sub-subject.
Map<String, Object?> itemsAnswer() => {
  'success': true,
  'itemsArray': [
    [
      {
        '_id': 'item-1',
        'name': 'Orta Asya',
        'desc': ['Birinci paragraf.', 'İkinci.'],
        'itemData': {
          '_id': 'prog-1',
          'status': 0,
          'statusArray': [0, 1, '0'],
          'itsIndependent': 0,
          'prompts': [
            {'title': 'Kart 1', 'content': 'Metin 1', 'isFavorite': true},
            {'title': 'Kart 2', 'text': 'Metin 2'},
            {'title': 'Kart 3'},
          ],
        },
      },
      {
        'name': 'Bağımsız',
        'itemData': {'status': '0', 'itsIndependent': '1'},
      },
      {'desc': 'no name'},
    ],
    [],
  ],
};

/// A sub-subject of Yazar & Eserler with the era's progress records.
Map<String, Object?> authorSubSubjectsAnswer() => {
  'success': true,
  'subSubjects': [
    {
      '_id': 'ss-era',
      'name': 'Divan Edebiyatı',
      'itemDataCount': 2,
      'itemDatas': [
        {
          '_id': 'rec-1',
          'status': 0,
          'statusArray': [0],
          'item': {
            'yazar': {'yazarCategory': 'era-1'},
          },
        },
        {
          '_id': 'rec-2',
          'status': 1,
          'statusArray': [1],
          'item': {
            'yazar': {'yazarCategory': 'era-1'},
          },
        },
        {
          '_id': 'rec-3',
          'status': 0,
          'item': {
            'yazar': {'yazarCategory': 'era-2'},
          },
        },
        {'_id': 'rec-4', 'status': 0},
      ],
    },
  ],
};

/// The era items `getItems` answers for [authorSubSubjectsAnswer].
Map<String, Object?> eraItemsAnswer() => {
  'success': true,
  'itemsArray': [
    [
      {'_id': 'era-1', 'name': '1. Dönem', 'desc': 'Dönem açıklaması'},
      {'_id': 'era-2', 'name': '2. Dönem'},
    ],
  ],
};

/// `getSubjectAuthors`: authors of an era with their works.
Map<String, Object?> authorsAnswer() => {
  'success': true,
  'authors': [
    {
      '_id': 'au-1',
      'name': 'Fuzuli',
      'desc': ['16. yüzyıl şairi.'],
      'image': '/authors/fuzuli.png',
      'itsYazar': 1,
      'yazarCategory': 'era-1',
      'isFavorite': false,
      'works': [
        {
          'eser': 'Leyla ile Mecnun',
          'type': '33',
          'itemData': {
            '_id': 'w-1',
            'status': '0',
            'statusArray': [0],
          },
        },
        {
          'eser': 'Su Kasidesi',
          'type': '1',
          'itemData': {
            '_id': 'w-2',
            'status': 1,
            'statusArray': [1],
          },
        },
        {'eser': 'Bilinmeyen tür', 'type': '99'},
        {'type': '1'},
      ],
    },
    {'name': 'Baki', 'itsYazar': 1, 'works': <Object>[]},
  ],
};

/// `getInfoCardsInfo`: counters per lesson under `infoData.infoObj`.
Map<String, Object?> cardsInfoAnswer() => {
  'success': true,
  'infoData': {
    'infoObj': {
      '663e37a24fb443839593141b': {
        'missCount': 12,
        'trueCount': '30',
        'favoriteCount': 2,
      },
      '66214a6982ff212039ea3294': {'missCount': 0},
    },
  },
};

/// `getLessonInfoCards`: the three decks.
Map<String, Object?> lessonCardsAnswer() => {
  'success': true,
  'data': {
    'failedCards': [
      {
        'favorite': 0,
        'item': {
          '_id': 'item-1',
          'name': 'Yavuz Selim Dönemi',
          'desc': ['Birinci.', 'İkinci.'],
          'mainSubject': {'name': 'Osmanlı Tarihi'},
        },
      },
      {
        'favorite': 1,
        'item': {'_id': 'item-2', 'name': 'Ridaniye', 'desc': 'Tek paragraf.'},
      },
    ],
    'successCards': [
      {
        'favorite': 0,
        'item': {'_id': 'item-3', 'name': 'Mercidabık', 'mainSubject': 'id-7'},
      },
    ],
    'favoriteCards': [
      {
        'favorite': 1,
        'item': {'_id': 'item-2', 'name': 'Ridaniye'},
      },
      {'favorite': 1, 'item': 'not an object'},
      {'favorite': 1},
      'junk',
    ],
  },
};

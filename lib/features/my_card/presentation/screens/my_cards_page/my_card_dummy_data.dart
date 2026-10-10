class MyCardDummyData {
  static const Map<String, dynamic> backendData = {
    'data': {
      '101': {'totalCards': 12, 'totalItems': 5, 'totalMapItems': 3},
      '102': {'totalCards': 8, 'totalItems': 14, 'totalMapItems': 0},
      '103': {'totalCards': 20, 'totalItems': 10, 'totalMapItems': 5},
      '104': {'totalCards': 15, 'totalItems': 2, 'totalMapItems': 1},
    },
  };

  static const Map<String, dynamic> mexam = {
    'lessonmockexams': [
      {'lesson': '101', 'net': 18.5, 'true': 19, 'wrong': 2},
      {'lesson': '102', 'net': 12.0, 'true': 14, 'wrong': 8},
      {'lesson': '103', 'net': 24.25, 'true': 25, 'wrong': 3},
      {'lesson': '104', 'net': 9.5, 'true': 11, 'wrong': 6},
    ],
  };

  static const Map<String, List<Map<String, dynamic>>> cardsDetailData = {
    '101': [
      {
        'title': 'Üslü Sayılar',
        'subtitle': 'Matematik - Konu Özeti',
        'content':
            'Bir sayının kendisi ile tekrarlı çarpımına üslü sayı denir.',
        'isFavorite': false,
      },
      {
        'title': 'Köklü Sayılar',
        'subtitle': 'Matematik - Formül',
        'content':
            'Kök içindeki sayıyı dışarı çıkarma kuralları çok önemlidir.',
        'isFavorite': true,
      },
    ],
    '102': [
      {
        'title': 'Hücre',
        'subtitle': 'Fen Bilimleri - Biyoloji',
        'content': 'Canlılık özelliği gösteren en küçük yapı birimidir.',
        'isFavorite': true,
      },
    ],
    '103': [
      {
        'title': 'Zarf (Belirteç)',
        'subtitle': 'Türkçe - Dilbilgisi',
        'content': 'Fiilleri, sıfatları niteleyen kelimelerdir.',
        'isFavorite': false,
      },
    ],
    '104': [
      {
        'title': 'Kavimler Göçü',
        'subtitle': 'Tarih - Olay',
        'content': '375 yılında Hunların baskısıyla başlayan göç.',
        'isFavorite': true,
      },
    ],
  };

  static const Map<String, Map<String, String>> lessonNameAndPhoto = {
    '101': {'name': 'MAT Matematik', 'image': 'assets/math.png'},
    '102': {'name': 'FEN Fen Bilimleri', 'image': 'assets/science.png'},
    '103': {'name': 'TRK Türkçe', 'image': 'assets/turkish.png'},
    '104': {'name': 'TAR Tarih', 'image': 'assets/history.png'},
  };
}

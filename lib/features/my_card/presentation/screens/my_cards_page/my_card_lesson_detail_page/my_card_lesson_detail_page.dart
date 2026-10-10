import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_card_lesson_detail_page/widgets/my_card_lesson_detail_header.dart';
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_cards_detail_page/my_cards_detail_page.dart';
import 'package:smap/repository/cards_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyCardLessonDetailPage extends StatefulWidget {
  const MyCardLessonDetailPage({
    super.key,
    required this.lessonId,
    required this.lessonName,
    required this.repository,
    required this.lesson,
    required this.onCountsChanged, // YENİ: Callback fonksiyonu eklendi
  });

  final String lessonId;
  final String lessonName;
  final CardsRepository repository;
  final dynamic lesson;
  final Function(int missCount, int trueCount, int favoriteCount)?
  onCountsChanged;
  @override
  State<MyCardLessonDetailPage> createState() => _MyCardLessonDetailPageState();
}

class _MyCardLessonDetailPageState extends State<MyCardLessonDetailPage> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;

  List<Map<String, dynamic>> _failedCards = [];
  List<Map<String, dynamic>> _successCards = [];
  List<Map<String, dynamic>> _favoriteCards = [];

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  List<Map<String, dynamic>> _formatCardList(List<dynamic> rawCards) {
    final List<Map<String, dynamic>> formatted = [];

    for (var obj in rawCards) {
      try {
        if (obj is Map && obj['item'] is Map) {
          final dynamic item = obj['item'];

          String title = 'Konu Analizi';
          if (item['mainSubject'] is Map) {
            title = item['mainSubject']['name']?.toString() ?? 'Konu Analizi';
          } else {
            print(
              "Uyarı: mainSubject populate edilmemiş, ID olarak geldi: ${item['mainSubject']}",
            );
          }

          formatted.add({
            'title': title,
            'subtitle': item['name']?.toString() ?? '',
            'content': item['desc'] is List
                ? (item['desc'] as List).join(' ')
                : (item['desc']?.toString() ?? ''),
            'itemId': item['_id']?.toString() ?? '',
            'isFavorite':
                obj['favorite'] ==
                1, // Alt sayfada favori durumunu korumak için ekledik
          });
        } else {
          print(
            "Format uyarısı: Gelen obje veya içindeki 'item' bir Map değil! Obje: $obj",
          );
        }
      } catch (cardError) {
        print(
          "Tekil bir kart formatlanırken hata oluştu: $cardError | Kart Datası: $obj",
        );
      }
    }
    return formatted;
  }

  Future<void> _fetchCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.repository.getLessonInfoCards(
        widget.lessonId,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        final List<dynamic> successRaw = data['successCards'] is List
            ? data['successCards']
            : [];
        final List<dynamic> favoriteRaw = data['favoriteCards'] is List
            ? data['favoriteCards']
            : [];
        final List<dynamic> failedRaw = data['failedCards'] is List
            ? data['failedCards']
            : [];

        _successCards = _formatCardList(successRaw);
        _favoriteCards = _formatCardList(favoriteRaw);
        _failedCards = _formatCardList(failedRaw);

        print(
          "Formatlama Sonrası -> Başarılı: ${_successCards.length}, Favori: ${_favoriteCards.length}, Hatalı: ${_failedCards.length}",
        );
      } else {
        print(
          "Backend response['success'] false döndü veya 'data' alanı null geldi!",
        );
      }
    } catch (e) {
      print("Kartlar çekilirken genel bir hata oluştu: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _notifyParentWithUpdatedCounts() {
    if (widget.onCountsChanged != null) {
      widget.onCountsChanged!(
        _failedCards.length,
        _successCards.length,
        _favoriteCards.length,
      );
    }
  }

  Widget _buildEmptyState(String message, {String? svgPath}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svgPath ?? 'assets/cards.svg', // SVG dosya yolunuz
            width: 72,
            height: 72,
            // Renk değiştirmek isterseniz ColorFilter kullanabilirsiniz:
            colorFilter: ColorFilter.mode(
              Colors.grey.shade400,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Liste uzunlukları değiştikçe countObj haritası da otomatik olarak güncel değerleri alır
    final Map<String, int> countObj = {
      'missCount': _failedCards.length,
      'trueCount': _successCards.length,
      'favoriteCount': _favoriteCards.length,
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: Column(
          children: [
            MyCardLessonDetailHeader(
              lessonName: widget.lessonName,
              selectedTabIndex: _selectedTabIndex,
              countObj: countObj,
              onTabSelected: (index) =>
                  setState(() => _selectedTabIndex = index),
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A237E),
                      ),
                    )
                  : IndexedStack(
                      index: _selectedTabIndex,
                      children: [
                        // 1. Sekme: Hatalı Kartlar
                        _failedCards.isEmpty
                            ? _buildEmptyState(
                                'Bu kategoride bilgi kartınız bulunmamaktadır.',
                              )
                            : MyCardsDetailPage(
                                key: ValueKey('failed_${_failedCards.length}'),
                                lessonName: widget.lessonName,
                                initialCards: _failedCards,
                                repository: widget.repository,
                                tabName: "failedCards",
                                onCardAction: (updatedCurrentTabCards, actionCard, action) {
                                  setState(() {
                                    // Hatalı kartlar listesini güncelle (Kart buradan silindi)
                                    _failedCards = updatedCurrentTabCards;
                                    // Eğer aksiyon 'başarılı olarak işaretle' ise, kartı Başarılı listesine ekle
                                    if (action ==
                                        CardSwipeAction.markedAsSuccess) {
                                      _successCards.insert(
                                        0,
                                        actionCard,
                                      ); // Başarılı listesinin en başına ekle
                                    } else if (action ==
                                        CardSwipeAction.toggleFavorite) {
                                      final bool isFavoriteNow =
                                          actionCard['isFavorite'] ?? false;

                                      if (isFavoriteNow) {
                                        // 1. Eğer favori yapıldıysa: Favori listesinin EN BAŞINA ekle
                                        _favoriteCards.insert(0, actionCard);
                                      } else {
                                        // 2. Eğer favoriden çıkarıldıysa: itemId'ye göre eşleşen kartı listeden temizle
                                        _favoriteCards.removeWhere(
                                          (card) =>
                                              card['itemId'] ==
                                              actionCard['itemId'],
                                        );
                                      }
                                    }
                                  });
                                  _notifyParentWithUpdatedCounts();
                                },
                              ),

                        // 2. Sekme: Başarılı Kartlar
                        _successCards.isEmpty
                            ? _buildEmptyState(
                                'Henüz başarılı kartınız bulunmuyor.',
                              )
                            : MyCardsDetailPage(
                                key: ValueKey(
                                  'success_${_successCards.length}',
                                ), // YENİ: Key eklendi
                                lessonName: widget.lessonName,
                                initialCards: _successCards,
                                repository: widget.repository,
                                tabName: "successCards",
                                onCardAction:
                                    (
                                      updatedCurrentTabCards,
                                      actionCard,
                                      action,
                                    ) {
                                      setState(() {
                                        _successCards = updatedCurrentTabCards;
                                      });
                                      _notifyParentWithUpdatedCounts();
                                    },
                              ),

                        // 3. Sekme: Favori Kartlar
                        _favoriteCards.isEmpty
                            ? _buildEmptyState(
                                'Favoriye eklenmiş kartınız bulunmuyor.',
                              )
                            : MyCardsDetailPage(
                                key: ValueKey(
                                  'favorite_${_favoriteCards.length}',
                                ), // YENİ: Key eklendi
                                lessonName: widget.lessonName,
                                initialCards: _favoriteCards,
                                repository: widget.repository,
                                tabName: "favoriteCards",
                                onCardAction:
                                    (
                                      updatedCurrentTabCards,
                                      actionCard,
                                      action,
                                    ) {
                                      setState(() {
                                        _favoriteCards = updatedCurrentTabCards;
                                        // Favorilerden çıkarılan kartın ana listelerdeki durumunu
                                        // bozmak istemiyorsak buraya ek bir listeye ekleme mantığı yazmıyoruz, sadece favoriden düşüyor.
                                      });
                                      _notifyParentWithUpdatedCounts();
                                    },
                              ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

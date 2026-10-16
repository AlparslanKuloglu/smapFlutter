import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:studentmap/features/my_card/presentation/screens/my_cards_page/my_cards_detail_page/widgets/my_card_info_card.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/repository/cards_repository.dart';

enum CardSwipeAction {
  markedAsSuccess, // Kart başarıyla öğrenildi (Doğru bilindi)
  toggleFavorite, // Kart favoriye eklendi veya çıkarıldı
}

class MyCardsDetailPage extends StatefulWidget {
  const MyCardsDetailPage({
    super.key,
    required this.lessonName,
    required this.initialCards,
    required this.repository,
    required this.tabName,
    this.onCardAction, // Yeni genişletilmiş callback fonksiyonumuz
  });

  final String lessonName;
  final List<dynamic> initialCards;
  final CardsRepository repository;
  final String tabName;
  // Kart listesi her güncellendiğinde veya sayfa kapandığında üst sayfaya güncel listeyi fırlatır
  final Function(
    List<Map<String, dynamic>> updatedCards,
    Map<String, dynamic> actionCard,
    CardSwipeAction action,
  )?
  onCardAction;
  @override
  State<MyCardsDetailPage> createState() => _MyCardsDetailPageState();
}

class _MyCardsDetailPageState extends State<MyCardsDetailPage> {
  final CardSwiperController _controller = CardSwiperController();
  late List<Map<String, dynamic>> _currentCards;
  int _currentIndex = 0;

  // O an sönme (Fade Out) animasyonunda olan kartın indeksini tutar
  int? _removingIndex;

  @override
  void initState() {
    super.initState();
    _currentCards = List<Map<String, dynamic>>.from(widget.initialCards);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Kartı Yavaşça Söndürerek Silen Fonksiyon
  void _removeCardAnimated(int index) {
    setState(() {
      _removingIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        if (index >= 0 && index < _currentCards.length) {
          // 1. İşlem gören kartın referansını kaybetmemek için kopyalıyoruz
          final Map<String, dynamic> removedCard = Map<String, dynamic>.from(
            _currentCards[index],
          );

          // 2. Mevcut sekme listesinden kartı siliyoruz
          _currentCards.removeAt(index);
          _removingIndex = null;

          // 3. Üst sayfaya detaylı haberi uçuruyoruz
          if (widget.onCardAction != null) {
            CardSwipeAction action = CardSwipeAction.markedAsSuccess;
            widget.onCardAction!(_currentCards, removedCard, action);
          }

          if (_currentIndex >= _currentCards.length &&
              _currentCards.isNotEmpty) {
            _currentIndex = _currentCards.length - 1;
          } else if (_currentCards.isEmpty) {
            _currentIndex = 0;
          }
        }
      });
    });
  }

  void addedFavorite(int index, String tabName, bool lastStatus) {
    setState(() {
      // 1. İlgili indeksteki kartın favori durumunu güncelle
      _currentCards[index]['isFavorite'] = lastStatus;
    });

    if (tabName == "favoriteCards" && lastStatus == false) {
      _removeCardAnimated(index);
    } else {
      if (widget.onCardAction != null) {
        CardSwipeAction action = CardSwipeAction.toggleFavorite;
        widget.onCardAction!(_currentCards, _currentCards[index], action);
      }
    }
  }

  void _handleDetailTap(Map<String, dynamic> data) {
    final ScrollController popupScrollController = ScrollController();
    bool isCardFavorite = data['isFavorite'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['subtitle'] ?? 'Detaylar',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.appBarBackground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['title']?.toUpperCase() ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isCardFavorite ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          ),
                          onPressed: () {
                            setPopupState(() {
                              isCardFavorite = !isCardFavorite;
                            });
                            setState(() {
                              data['isFavorite'] = isCardFavorite;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFF5F5F5)),
                    Flexible(
                      child: Scrollbar(
                        controller: popupScrollController,
                        thumbVisibility: true,
                        thickness: 3.0,
                        radius: const Radius.circular(8),
                        child: SingleChildScrollView(
                          controller: popupScrollController,
                          padding: const EdgeInsets.only(right: 16, bottom: 8),
                          child: Text(
                            data['content'] ?? 'İçerik bulunamadı.',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFF5F5F5)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Kapat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8F9FA),
      child: SafeArea(
        child: _currentCards.isEmpty
            ? const Center(child: Text('Görüntülenecek kart kalmadı.'))
            : Column(
                children: [
                  // Üst Kısım: Sayaç (Indicator)
                  Container(
                    // İçerideki metnin kenarlardan uzaklığı (Hafif bir nefes payı)
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      // Gri çerçeve rengi ve kalınlığı
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                      // Köşe ovaliği (İstediğiniz gibi artırıp azaltabilirsiniz)
                      borderRadius: BorderRadius.circular(12.0),
                      // İsteğe bağlı: Arka planı hafif gri ya da beyaz yapmak isterseniz
                      color: Colors.grey.shade50,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${(_currentIndex >= _currentCards.length ? _currentCards.length - 1 : _currentIndex) + 1}',
                            style: const TextStyle(
                              color: AppColors.appBarBackground,
                            ),
                          ),
                          const TextSpan(
                            text: ' / ',
                            style: TextStyle(color: Colors.black54),
                          ),
                          TextSpan(
                            text: '${_currentCards.length}',
                            style: const TextStyle(
                              color: AppColors.appBarBlueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Swiper Alanı
                  Expanded(
                    child: CardSwiper(
                      controller: _controller,
                      key: ValueKey(_currentCards.length),
                      cardsCount: _currentCards.length,
                      onSwipe: (previousIndex, currentIndex, direction) {
                        if (currentIndex != null) {
                          setState(() {
                            _currentIndex = currentIndex;
                          });
                        }
                        return true;
                      },
                      cardBuilder: (context, index, percentX, percentY) {
                        if (index < 0 || index >= _currentCards.length) {
                          return const SizedBox.shrink();
                        }
                        final cardData = _currentCards[index];

                        // Bu kartın sönme aşamasında olup olmadığının kontrolü
                        final bool isThisCardRemoving = _removingIndex == index;

                        // Fade Out için kartı AnimatedOpacity ile sarmalıyoruz
                        return AnimatedOpacity(
                          opacity: isThisCardRemoving
                              ? 0.0
                              : 1.0, // Siliniyorsa sıfıra sön
                          duration: const Duration(
                            milliseconds: 300,
                          ), // Sönme süresi
                          curve: Curves.easeOut, // Yumuşak çıkış eğrisi
                          child: MyCardInfoCard(
                            data: cardData,
                            isFavorite: cardData['isFavorite'] ?? false,
                            onDetailTap: () {
                              _handleDetailTap(cardData);
                            },
                            repository: widget.repository,
                            tabName: widget.tabName,
                            onRemove: () => _removeCardAnimated(index),
                            onFavoriteStatusChanged: (newStatus) => addedFavorite(
                              index,
                              widget.tabName,
                              newStatus, // Artık en güncel veri güvenle üst fonksiyona gidiyor!
                            ),
                          ),
                        );
                      },
                      numberOfCardsDisplayed: _currentCards.length > 1 ? 2 : 1,
                      backCardOffset: const Offset(0, 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

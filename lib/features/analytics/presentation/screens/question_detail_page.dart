import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:studentmap/repository/analysis_repository.dart';
import 'package:studentmap/core/theme/app_colors.dart';

class QuestionDetailsPage extends StatefulWidget {
  final Map<String, dynamic> question;
  final int subjectIndex; // Tip eklendi
  final String subjectName; // Tip eklendi
  final dynamic mexam; // Projenize göre uygun tipi yazın (örn: ExamModel)
  final AnalysisRepository analysisRepository;

  const QuestionDetailsPage({
    super.key,
    required this.question,
    required this.subjectIndex,
    required this.subjectName,
    required this.mexam,
    required this.analysisRepository, // Zorunlu hale getirildi
  });

  @override
  State<QuestionDetailsPage> createState() => _QuestionDetailsPageState();
}

class _QuestionDetailsPageState extends State<QuestionDetailsPage>
    with SingleTickerProviderStateMixin {
  final CardSwiperController controller = CardSwiperController();
  late TabController _tabController;
  int currentIndex = 1;
  // Future değişkenimiz
  late Future<Map<String, dynamic>> _questionDetailFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Repository isteğini başlatıyoruz
    _questionDetailFuture = _fetchRepositoryData();
  }

  Future<Map<String, dynamic>> _fetchRepositoryData() async {
    try {
      final int questionOrder =
          int.tryParse(widget.question['order']?.toString() ?? '') ?? 1;
      final int lessonOrder =
          int.tryParse(widget.subjectIndex?.toString() ?? '') ?? 1;

      final Map<String, dynamic> result = await widget.analysisRepository
          .getQuestion(
            mexam: widget.mexam['mexam'],
            questionOrder: questionOrder,
            lessonOrder: lessonOrder,
          );

      final dynamic question = result['question'];

      // 1. API'den gelen ana açıklamaları güvenli bir şekilde alıyoruz
      final String description = question['desc']?.toString() ?? '';
      final String pageInfo = question['page_info']?.toString() ?? '';

      // 2. items listesini for döngüsü (veya map) ile cards formatına çeviriyoruz
      final List<dynamic> rawItems = question['items'] is List
          ? question['items']
          : [];
      final List<Map<String, dynamic>> formattedCards = [];

      for (var item in rawItems) {
        if (item is Map) {
          formattedCards.add({
            // Eğer API'den 'mainSubjectName' veya 'konuName' gibi ana başlıklar geliyorsa buraya yazabilirsin.
            // Şimdilik boş kalmasın diye sabit veya var olan 'name' alanını yerleştirelim:
            'title': item['mainSubject']?['name'].toString() ?? 'Konu Analizi',

            // 'name' alanı mock verideki 'subtitle' kısmına çok iyi oturuyor (Örn: Türk Devlet Geleneğinin Oluşumunda...)
            'subtitle': item['name']?.toString() ?? '',

            // 'desc' alanı bir liste veya string olabilir, liste ise join ile birleştiriyoruz
            'content': item['desc'] is List
                ? (item['desc'] as List).join(' ')
                : (item['desc']?.toString() ?? ''),
          });
        }
      }

      // 3. UI'ın beklediği mock data formatında yeni bir Map oluşturup döndürüyoruz
      final Map<String, dynamic> transformedResult = {
        'description': description,
        'page_info': pageInfo,
        'cards': formattedCards,
      };

      return transformedResult;
    } catch (e) {
      rethrow;
    }
  }

  // API İstek
  Future<Map<String, dynamic>> _fetchMockRepositoryData() async {
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // 1.5 saniye yüklenme simülasyonu
    return {
      'description':
          "Bu soru 1. Kosova Savaşı'nın barutlu silahların kullanımı açısından önemini yorumlamanı istedi.",
      'page_info':
          "Bu soru optik formunuzdaki 5. sayfa da, soldan 4. sırada fdgfdgdf almaktadır.",
      'cards': [
        {
          'title': 'Tarih / Osmanlı Tarihi',
          'subtitle': 'Yavuz Selim Dönemi',
          'content':
              'Osmanlı devleti ile Memluk devleti arasındaki ilişkiler 15. yüzyıl sonlarına doğru bozulmaya başlamıştır. Temel sebep Hicaz su yolları meselesidir.',
        },
        {
          'title': 'Tarih / Osmanlı Tarihi',
          'subtitle': 'Mercidabık Savaşı',
          'content':
              '1516 yılında Memluk Devleti ile yapılan bu savaş sonucunda Suriye ve Filistin toprakları Osmanlı denetimine geçmiştir.',
        },
        {
          'title': 'Tarih / Osmanlı Tarihi',
          'subtitle': 'Ridaniye Savaşı',
          'content':
              '1517 yılında Kahire yakınlarında yapılan savaşla Memluk Devleti yıkılmış, halifelik Osmanlılara geçmiştir.',
        },
      ],
    };
  }

  @override
  void dispose() {
    controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // --- MAVİ HEADER (HER ZAMAN SABİT VE GÖRÜNÜR) ---
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '${widget.subjectName ?? ''}  ${widget.question['order'] ?? ''}. Soru',
                          maxLines: 1,
                          overflow: TextOverflow
                              .ellipsis, // Başlık çok uzun olursa taşmayı önler
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),
                // --- TAB SEÇİCİ ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: AppColors.accentOrange,
                      unselectedLabelColor: AppColors.unselectedGrey,
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_outlined, size: 18),
                              SizedBox(width: 8),
                              Text("Soru Analizi"),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_search_rounded, size: 18),
                              SizedBox(width: 8),
                              Text("Soru Fotoğrafı"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- VERİ BEKLEYEN VE DEĞİŞEN ALT BÖLÜM ---
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _questionDetailFuture,
              builder: (context, snapshot) {
                // A Durumu: Mavi header'ın altında loader ortalansın
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentOrange,
                    ),
                  );
                }

                // B Durumu: Hata durumu yönetimi
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Soru detayları yüklenirken bir hata oluştu:\n${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.appBarBackground,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _questionDetailFuture =
                                    _fetchMockRepositoryData();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                            ),
                            child: const Text(
                              "Tekrar Dene",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // C Durumu: Veri boş gelirse
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Soruya ait detay verisi bulunamadı."),
                  );
                }

                // D Durumu: Başarılı! Veriyi arayüze dağıtıyoruz
                final responseData = snapshot.data!;
                final List<dynamic> cards = responseData['cards'] ?? [];
                final String description = responseData['description'] ?? '';

                return TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // 1. SEKME: ANALİZ (KOMPLE)
                    _buildTabBlock(
                      descriptionWidget: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.appBarBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      child: cards.isEmpty
                          ? const Center(
                              child: Text("Analiz kartı bulunamadı."),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: CardSwiper(
                                    controller: controller,
                                    cardsCount: cards.length,
                                    numberOfCardsDisplayed: cards.length > 1
                                        ? 2
                                        : 1,
                                    backCardOffset: const Offset(0, 40),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 30,
                                    ),
                                    onSwipe: (p, c, d) {
                                      setState(
                                        () => currentIndex = (c ?? 0) + 1,
                                      );
                                      return true;
                                    },
                                    cardBuilder: (context, index, x, y) {
                                      final cardData =
                                          Map<String, dynamic>.from(
                                            cards[index],
                                          );
                                      return _buildInfoCard(
                                        cardData,
                                        isFavorite: isCardFavorite,
                                        onFavoriteTap: _handleFavoriteTap,
                                        onDetailTap: () =>
                                            _handleDetailTap(cardData),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Text(
                                    '$currentIndex / ${cards.length}',
                                    style: const TextStyle(
                                      color: AppColors.appBarBackground,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),

                    // 2. SEKME: FOTOĞRAF (KOMPLE)
                    _buildTabBlock(
                      descriptionWidget: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              children: [
                                const TextSpan(text: "Soruyu kaydederek "),
                                TextSpan(
                                  text: "Soru Bankam",
                                  style: TextStyle(
                                    color: AppColors
                                        .accentOrange, // Veya vurgu renginiz neyse
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(text: " modülüne aktarırsın ve"),
                                TextSpan(
                                  text: " PDF",
                                  style: TextStyle(
                                    color: AppColors
                                        .accentOrange, // PDF kelimesi için de aynı dinamik vurgu rengi
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      " çıktıları alabilirsin.", // Bu sayede 0 Hata Kitapçığını aylarca beklemezsin.
                                ),
                              ],
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.appBarBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 30,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_enhance_rounded,
                                  color: AppColors.accentOrange,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Soru Fotoğrafı",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.appBarBackground,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  "Sorunun fotoğrafı Smap'de mevcut ancak telif hakları sebebiyle sizinle paylaşamamaktayız.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildPhotoButton(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Yardımcı Tasarım Widget'ları ---
  Widget _buildTabBlock({
    required Widget descriptionWidget,
    required Widget child,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 85),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentOrange.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: descriptionWidget),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildPhotoButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_rounded, size: 22),
            SizedBox(width: 12),
            Text(
              "Fotoğraf Çek",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Favori durumunu takip eden değişkeniniz (örneğin)
  bool isCardFavorite = false;

  void _handleFavoriteTap() {
    setState(() {
      isCardFavorite = !isCardFavorite;
    });

    // İsteğe bağlı: Burada veritabanı veya API güncellemesi yapabilirsiniz
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCardFavorite ? 'Favorilere eklendi!' : 'Favorilerden çıkarıldı!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleDetailTap(Map<String, dynamic> data) {
    // Pop-up içindeki Scrollbar için bağımsız bir controller
    final ScrollController popupScrollController = ScrollController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder kullanıyoruz ki pop-up açıkken yıldıza basılırsa
        // anlık olarak pop-up içindeki yıldızın da içi dolsun/boşalsın.
        return StatefulBuilder(
          builder: (context, setPopupState) {
            return Dialog(
              // insetPadding ile pop-up'ın ekran kenarlarına olan mesafesini minimuma indiriyoruz (Geniş pop-up)
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                height:
                    MediaQuery.of(context).size.height *
                    0.7, // Ekran yüksekliğinin %70'i kadar olsun (Örn: 0.5 yaparsan %50 olur)
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Üst Başlık ve Yıldız Bölümü
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
                        // Pop-up İçindeki Favori Yıldızı
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isCardFavorite ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          ),
                          onPressed: () {
                            // 1. Pop-up içerisindeki arayüzü günceller
                            setPopupState(() {
                              isCardFavorite = !isCardFavorite;
                            });
                            // 2. Ana sayfadaki (arka plandaki) kartın yıldızını günceller
                            setState(() {});
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 24, color: Color(0xFFF5F5F5)),

                    // İçerik ve İnce Scrollbar Bölümü
                    Flexible(
                      child: Scrollbar(
                        controller: popupScrollController,
                        thumbVisibility: true,
                        thickness: 3.0, // İnce scrollbar
                        radius: const Radius.circular(8),
                        child: SingleChildScrollView(
                          controller: popupScrollController,
                          // Sağ taraftan scrollbar çubuğu için ekstra boşluk bıraktık (right: 16)
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

                    // Kapat Butonu
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

  Widget _buildInfoCard(
    Map<String, dynamic> data, {
    required bool isFavorite,
    required VoidCallback onFavoriteTap,
    required VoidCallback onDetailTap,
  }) {
    // Scrollbar'ın düzgün tetiklenmesi için controller tanımlıyoruz
    final ScrollController cardScrollController = ScrollController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Başlık Bölümü
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/icons/historybook2.png', // Görselinin tam dosya yolu
                    width:
                        22, // Eski ikonun boyutu (size: 22) ile eşitlemek için
                    height: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: Color.fromARGB(255, 234, 235, 238),
            indent: 16, // Çizginin solundan bırakılacak boşluk
            endIndent: 16, // Çizginin sağından bırakılacak boşluk
          ),
          // İçerik ve Scrollbar Bölümü
          Expanded(
            child: Scrollbar(
              controller: cardScrollController,
              thumbVisibility: true, // Kaydırırken çubuk hep görünsün
              thickness: 3.0, // İnce bir görünüm için kalınlık değeri
              radius: const Radius.circular(
                8,
              ), // Çubuğun yuvarlatılmış köşeleri
              child: SingleChildScrollView(
                controller: cardScrollController,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  left: 20,
                  right: 26,
                ), // Sağdan boşluğu çubuk için biraz artırdık
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            data['subtitle'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 26,
                          ),
                          onPressed: onFavoriteTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['content'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(
            height: 0,
            color: Color.fromARGB(255, 234, 235, 238),
            indent: 16, // Çizginin solundan bırakılacak boşluk
            endIndent: 16, // Çizginin sağından bırakılacak boşluk
          ),
          // Detay Butonu Bölümü
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onDetailTap,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF0F294A),

                  // 1. Material Design'ın buton etrafındaki zorunlu tıklama alanını kaldırır
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                  // 2. Butonun gizli 48px olan varsayılan alt sınır yüksekliğini sıfırlar
                  minimumSize: Size.zero,

                  // 3. Şimdi verdiğin bu küçük padding değerleri gerçekten işe yarayacak
                  padding: const EdgeInsets.symmetric(
                    horizontal:
                        16, // Yatayda yazının nefes alması için idealdır
                    vertical:
                        6, // Dikeydeki inceliği/kalınlığı tamamen buradan yönetebilirsin
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Detay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // En Alttaki Dekoratif Alan
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/core/constants/lesson_constants.dart';
import 'package:studentmap/repository/weekly_repository.dart';

class AddTopicPopup extends StatefulWidget {
  const AddTopicPopup({
    super.key,
    required this.bagItemsStr,
    required this.initialTab,
    required this.repository,
  });
  final String? bagItemsStr;
  final String initialTab; // Yeni eklenen parametre
  final WeeklyRepository repository;

  @override
  State<AddTopicPopup> createState() => _AddTopicPopupState();
}

class _AddTopicPopupState extends State<AddTopicPopup> {
  int _activeTabIndex = 0;
  List<dynamic> _bagItems = [];
  String? _selectedLessonId;
  bool _isLoadingSubjects = true; // Veri yüklenirken yükleniyor göstermek için

  static const List<Map<String, dynamic>> allLessons = AppLessons.allLessons;

  // Tip hatasını düzeltmek için değişken türünü dynamic veya doğru eşleşen Map yapıyoruz
  Map<String, dynamic> subjectsJson = {};

  @override
  void initState() {
    super.initState();
    _activeTabIndex = (widget.initialTab == 'lessons') ? 1 : 0;

    // Asenkron veri çekme fonksiyonunu tetikliyoruz
    _fetchSubjects();

    if (widget.bagItemsStr != null && widget.bagItemsStr!.isNotEmpty) {
      try {
        _bagItems = jsonDecode(widget.bagItemsStr!);
      } catch (e) {
        debugPrint("JSON Parse Hatası: $e");
      }
    }
  }

  // Future fonksiyonu bekleyen yeni asenkron metodumuz
  Future<void> _fetchSubjects() async {
    // Eğer subjectsJson zaten doluysa (null değilse ve boş değilse) isteği atma
    if (subjectsJson != null && subjectsJson.isNotEmpty) {
      return;
    }

    try {
      // Yükleme durumunu başlat (Eğer ilk kez yükleniyorsa)
      setState(() {
        _isLoadingSubjects = true;
      });

      final data = await widget.repository.getAllMainSubjects();
      if (data['success']) {
        final subjects = data['subjectsJson'];

        setState(() {
          subjectsJson = subjects;
          _isLoadingSubjects = false; // Yükleme tamamlandı
        });
      }
    } catch (e) {
      debugPrint("Konular yüklenirken hata oluştu: $e");
      setState(() {
        _isLoadingSubjects = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final popupMaxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.95,
        height: popupMaxHeight,
        child: Column(
          children: [
            // Kapatma Butonu ve Başlık Alanı
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Konu Seçimi Yapın',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Çantam / Dersler Segment Yapısı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeTabIndex = 0;
                            _selectedLessonId =
                                null; // Sekme değişince ders seçimini sıfırla
                          });
                        },
                        child: _PopupTabChip(
                          label: 'Çantam',
                          count: _bagItems.length, // Badge'e gönderiyoruz
                          isSelected: _activeTabIndex == 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _activeTabIndex = 1;
                            _selectedLessonId =
                                null; // Sekme değişince ders seçimini sıfırla
                          });
                        },
                        child: _PopupTabChip(
                          label: 'Dersler',
                          isSelected: _activeTabIndex == 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Liste İçeriği (Aktif sekmeye göre değişen alan)
            Expanded(
              child: _activeTabIndex == 0
                  ? _buildBagContent()
                  : _buildLessonsContent(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Gerçek Veriyle Çalışan Çantam Listesi
  Widget _buildBagContent() {
    if (_bagItems.isEmpty) {
      return const Center(
        child: Text(
          'Çantanızda konu bulunamadı.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _bagItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        // Her bir elemanı Map (Key-Value) olarak alıyoruz
        final Map<String, dynamic> item = _bagItems[index];

        // JSON içindeki "data" ve "lesson" objelerine doğrudan erişim
        final Map<String, dynamic> topicData = item['data'] ?? {};
        final Map<String, dynamic> lessonData = item['lesson'] ?? {};
        final String itemLessonId = lessonData['_id'];

        final Map<String, dynamic> selectedLesson = allLessons.firstWhere(
          (element) => element['_id'] == itemLessonId,
          orElse: () =>
              {}, // Eğer eşleşen ders bulunamazsa çökmemesi için boş map döndürür
        );

        final String assetPath = selectedLesson['mapImage'];

        return ListTile(
          dense: true,
          tileColor: AppColors.menuCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          leading: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            // Eğer asset bulunamazsa uygulamanın çökmemesi için hata durumunda varsayılan bir ikon gösterir
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.menu_book_rounded,
                color: Colors.blue,
                size: 20,
              );
            },
          ),
          title: Text(
            topicData['name'] ?? 'Bilinmeyen Konu', // "Tarih Biliminin Tanımı"
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            lessonData['name'] ?? 'Bilinmeyen Ders', // "TYT Tarih"
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          trailing: const Icon(
            Icons.add_circle_outline_rounded,
            size: 20,
            color: AppColors.appBarBackground,
          ),
          onTap: () {
            // Seçilen Map objesini direkt geri döndürüyoruz
            Navigator.pop(context, item);
          },
        );
      },
    );
  }

  // Dersler ve Konular İçeriği
  Widget _buildLessonsContent() {
    // Eğer bir ders seçildiyse o dersin konularını göster
    if (_selectedLessonId != null) {
      return _buildSubjectsList();
    }

    // Herhangi bir ders seçilmediyse dersleri listele
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: allLessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final lesson = allLessons[index];

        // Asset yolunu dinamik olarak alıyoruz (Örn: assets/icons/biyoloji.png veya fizik.png)
        // .toLowerCase() ekleyerek sunucudaki yeni küçük harf standardıyla eşleşmesini garanti ediyoruz.
        final String imageName = (lesson['mapImage'] ?? 'book.png')
            .toString()
            .toLowerCase();
        final String assetPath =
            '$imageName'; // Kendi asset klasör yoluna göre burayı düzenleyebilirsin

        return ListTile(
          dense: true,
          tileColor: AppColors.menuCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // ÇÖZÜM: Sabit Icon yerine Image.asset widget'ı yerleştirildi
          leading: Image.asset(
            assetPath,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            // Eğer asset bulunamazsa uygulamanın çökmemesi için hata durumunda varsayılan bir ikon gösterir
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.menu_book_rounded,
                color: Colors.blue,
                size: 20,
              );
            },
          ),
          title: Text(
            lesson['name'] ?? 'Bilinmeyen Ders',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20),
          onTap: () {
            // Tıklanan dersin id'sini state'e ata ve arayüzü yenile
            setState(() {
              _selectedLessonId = lesson['_id'];
            });
          },
        );
      },
    );
  }

  // Seçilen Dersin Konularını Listeleyen Widget
  Widget _buildSubjectsList() {
    // ÇÖZÜM: .from() veya .cast() kullanarak List<dynamic> türünü List<Map<String, dynamic>> yapısına dönüştürüyoruz.
    final List<Map<String, dynamic>> subjects =
        subjectsJson[_selectedLessonId] != null
        ? List<Map<String, dynamic>>.from(subjectsJson[_selectedLessonId])
        : [];

    final Map<String, dynamic> selectedLesson = allLessons.firstWhere(
      (element) => element['_id'] == _selectedLessonId,
      orElse: () =>
          {}, // Eğer eşleşen ders bulunamazsa çökmemesi için boş map döndürür
    );

    return Column(
      children: [
        // Geri Dön Butonu ve Seçili Ders Adı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedLessonId =
                    null; // Geri dönüldüğünde ders seçimini temizle
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedLesson['name'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appBarBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 16, // Divider'ın kapladığı toplam dikey alan
          thickness: 2.0, // Çizginin kendi kalınlığı
          color:
              selectedLesson['lessonColor'], // Vermek istediğiniz renk (Örn: primaryOrange)
        ), // Konu Listesi
        Expanded(
          child: subjects.isEmpty
              ? const Center(
                  child: Text(
                    'Bu derse ait konu bulunamadı.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return ListTile(
                      dense: true,
                      tileColor: AppColors.menuCardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: Text(
                        subject['name'] ?? 'Bilinmeyen Konu',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                        color: AppColors.appBarBackground,
                      ),
                      onTap: () {
                        // Çantam listesindeki ile aynı mantıkta (data ve lesson objesi) geri döndürüyoruz
                        Navigator.pop(context, {
                          "data": subject,
                          "lesson": selectedLesson,
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PopupTabChip extends StatelessWidget {
  const _PopupTabChip({
    required this.label,
    required this.isSelected,
    this.count, // Yeni: Sayı parametresi eklendi
  });

  final String label;
  final bool isSelected;
  final int? count; // Eğer sayı varsa gösterilecek

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.primaryOrange, // Turuncu yazı
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

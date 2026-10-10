import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:smap/core/constants/lesson_constants.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/domain/models/general_lessons.dart';
import 'package:smap/features/analytics/presentation/screens/lesson_bar.dart';
import 'package:smap/features/home/presentation/provider/home_provider.dart';
import 'package:smap/features/home/presentation/widgets/lesson_navigation_helper.dart';
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_card_lesson_detail_page/my_card_lesson_detail_page.dart';
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_card_page/widgets/my_card_header.dart';
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_card_page/widgets/my_card_lesson_grid_item.dart';
import 'package:smap/repository/cards_repository.dart';

class MyCardPage extends StatefulWidget {
  const MyCardPage({super.key, required this.repository});
  final CardsRepository repository;

  @override
  State<MyCardPage> createState() => _MyCardPageState();
}

class _MyCardPageState extends State<MyCardPage> {
  Map<String, dynamic> _processedData = {};
  int _totalInfoCard = 0;
  String _selectedTab = 'TYT';

  // Backend'den gelecek istatistik verisini tutacağımız map
  Map<String, dynamic> _infoData = {};
  // İstek atılırken loading göstermek için tuttuğumuz değişken
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Asenkron isteğimizi başlatıyoruz
    _fetchInfoCards();
  }

  // Repository'den veriyi çeken fonksiyon
  Future<void> _fetchInfoCards() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.repository.getInfoCardsInfo();

      if (response != null && response['success'] == true) {
        _infoData = response['infoData'] ?? {};
      }
    } catch (e) {
      print("İstatistikler çekilirken hata oluştu: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _processData(List<GeneralLesson> homeLessons) {
    _processedData = {};
    _totalInfoCard = 0;

    final int targetType = _selectedTab == 'TYT' ? 1 : 2;

    final filteredLessons = AppLessons.allLessons.where((lesson) {
      return lesson['type'] == targetType;
    }).toList();

    final dynamic infoObj = _infoData.containsKey('infoObj')
        ? _infoData['infoObj']
        : null;

    for (final lessonStatic in filteredLessons) {
      final lessonId = lessonStatic['_id'].toString();
      final lessonDetail = Map<String, dynamic>.from(lessonStatic);

      final Map<String, dynamic> lessonStats =
          (infoObj != null && infoObj[lessonId] != null)
          ? Map<String, dynamic>.from(infoObj[lessonId])
          : {};

      lessonDetail['missCount'] = lessonStats['missCount'] ?? 0;
      lessonDetail['trueCount'] = lessonStats['trueCount'] ?? 0;
      lessonDetail['favoriteCount'] = lessonStats['favoriteCount'] ?? 0;

      // --- HOME PROVIDER ILE GENERAL LESSON EŞLEŞTİRME ---
      final String rawLessonName = (lessonDetail['name'] ?? '').toString();

      final GeneralLesson matchedLesson = homeLessons.firstWhere((general) {
        final String generalName = general.name;
        return rawLessonName == generalName ||
            rawLessonName.contains(generalName) ||
            generalName.contains(rawLessonName);
      }, orElse: () => GeneralLesson.empty());

      lessonDetail['generalLesson'] = matchedLesson.toJson();

      final cards = (lessonDetail['totalCards'] ?? 0) as int;
      final items = (lessonDetail['totalItems'] ?? 0) as int;
      final mapItems = (lessonDetail['totalMapItems'] ?? 0) as int;

      _totalInfoCard += cards + items + mapItems;
      _processedData[lessonId] = lessonDetail;
    }
  }

  void _openLessonDetail(String lessonId, Map<String, dynamic> lesson) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyCardLessonDetailPage(
          lessonId: lessonId,
          lesson: lesson,
          lessonName: lesson['name'].toString(),
          repository: widget.repository,
          onCountsChanged: (missCount, trueCount, favoriteCount) {
            _updateLessonCounts(lessonId, missCount, trueCount, favoriteCount);
          },
        ),
      ),
    );
  }

  void _updateLessonCounts(
    String lessonId,
    int missCount,
    int trueCount,
    int favoriteCount,
  ) {
    if (mounted) {
      setState(() {
        // 1. Eğer ham infoData varsa onun içini güncelle
        if (_infoData.containsKey('infoObj') && _infoData['infoObj'] != null) {
          if (_infoData['infoObj'][lessonId] != null) {
            _infoData['infoObj'][lessonId]['missCount'] = missCount;
            _infoData['infoObj'][lessonId]['trueCount'] = trueCount;
            _infoData['infoObj'][lessonId]['favoriteCount'] = favoriteCount;
          } else {
            _infoData['infoObj'][lessonId] = {
              'missCount': missCount,
              'trueCount': trueCount,
              'favoriteCount': favoriteCount,
            };
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch sayesinde HomeProvider verisi güncellendiğinde build tekrar tetiklenir
    final homeProvider = context.watch<HomeProvider>();

    // Provider'dan gelen güncel ders listesiyle veriyi işliyoruz
    _processData(homeProvider.lessons);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyCardHeader(
              title: '',
              selectedTab: _selectedTab,
              onTabChanged: (tab) {
                setState(() {
                  _selectedTab = tab;
                });
              },
            ),
            Expanded(
              child: (_isLoading || homeProvider.isLoading)
                  ? const Center(child: CircularProgressIndicator())
                  : _buildGridView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    final keys = _processedData.keys.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _processedData.isEmpty
                ? const Center(child: Text('Henüz veri bulunamadı.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 0),
                    itemCount: _processedData.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final lessonId = keys[index];
                      final lesson =
                          _processedData[lessonId] as Map<String, dynamic>? ??
                          {};

                      // Kart/Item sayısını hesaplama
                      final cards = (lesson['totalCards'] ?? 0) as int;
                      final items = (lesson['totalItems'] ?? 0) as int;
                      final mapItems = (lesson['totalMapItems'] ?? 0) as int;
                      final cardCount = cards + items + mapItems;

                      // Dinamik veri okuma
                      final String topicName =
                          lesson['name'] as String? ?? 'Bilinmeyen Konu';
                      final int order = (lesson['order'] as num? ?? (index + 1))
                          .toInt();
                      final String lessonImage =
                          lesson['lessonImage']?.toString() ?? '';

                      // Renk dönüşümleri
                      final Color barColor = AppColors.hexToColor(
                        lesson['barColor']?.toString() ?? '#FFFFFF',
                      );

                      final Color imageColor = AppColors.hexToColor(
                        lesson['lessonColor']?.toString() ?? '#FFFFFF',
                      );

                      final generalLesson =
                          lesson['generalLesson'] as Map<String, dynamic>? ??
                          {};

                      return LessonBar(
                        topicId: lessonId,
                        topicName: topicName,
                        order: order,
                        itemDataCount: cardCount,
                        subjectImage: lessonImage,
                        barColor: barColor,
                        imageColor: imageColor,
                        onTap: () => LessonNavigationHelper.showTypeSelection(
                          context,
                          generalLesson,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

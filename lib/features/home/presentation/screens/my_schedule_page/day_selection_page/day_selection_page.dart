import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/add_lessons_page/add_lessons_page.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/add_lessons_page/widgets/add_lessons_top_header.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/day_selection_page/widgets/day_selection_body.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/day_selection_page/widgets/day_selection_empty_dialog.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/day_selection_page/widgets/day_selection_top_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/features/home/presentation/screens/my_schedule_page/add_lessons_page/widgets/add_topic_popup.dart';
import 'package:smap/repository/weekly_repository.dart';
import 'dart:convert'; // 🔴 DOSYANIN EN ÜSTÜNE BU IMPORT'U EKLEMEYİ UNUTMA

enum _DaySelectionStep { calendar, addLessons }

class DaySelectionPage extends StatefulWidget {
  const DaySelectionPage({
    super.key,
    required this.repository,
    required this.allLessons,
    this.initialSchedule, // 🔴 YENİ: Dışarıdan seçilen programı almak için
  });

  final WeeklyRepository repository;
  final dynamic allLessons;
  final Map<String, dynamic>? initialSchedule; // 🔴 YENİ

  // ÇÖZÜM: open metoduna hem repository hem de allLessons parametrelerini ekledik
  static Future<dynamic> open(
    BuildContext context, {
    required WeeklyRepository repository,
    required dynamic allLessons,
    Map<String, dynamic>? initialSchedule,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DaySelectionPage(
          repository: repository,
          allLessons: allLessons,
          initialSchedule: initialSchedule,
        ),
      ),
    );
  }

  @override
  State<DaySelectionPage> createState() => _DaySelectionPageState();
}

class _DaySelectionPageState extends State<DaySelectionPage> {
  _DaySelectionStep _step = _DaySelectionStep.calendar;
  final Set<DateTime> _selectedDays = {};
  String? _bagItemsStr;
  Map<String, dynamic>? _pendingSubject;
  @override
  void initState() {
    super.initState();
    // 2. Sayfa açılır açılmaz veriyi yükleyecek fonksiyonu çağırıyoruz
    _loadBagItem();

    if (widget.initialSchedule != null) {
      // 1. Durumu direkt ders ekleme adımına getiriyoruz
      _step = _DaySelectionStep.addLessons;

      final contentRaw = widget.initialSchedule!['content'];
      List<dynamic> contentList = [];

      // 🔴 ÇÖZÜM: Eğer veri bir String ise parse ediyoruz, zaten List ise direkt alıyoruz
      if (contentRaw is String) {
        contentList = jsonDecode(contentRaw) as List<dynamic>? ?? [];
      } else if (contentRaw is List) {
        contentList = contentRaw;
      }

      for (var task in contentList) {
        if (task['day'] != null) {
          final parsedDate = DateTime.tryParse(task['day'].toString());
          if (parsedDate != null) {
            // dateKey fonksiyonunu kullanarak güvenli şekilde ekliyoruz
            _selectedDays.add(_dateKey(parsedDate));
          }
        }
      }
    }
  }

  Future<void> _openBagPopup(String tabName) async {
    final Map<String, dynamic>? selectedItem =
        await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => AddTopicPopup(
            bagItemsStr: _bagItemsStr,
            initialTab: tabName,
            repository: widget
                .repository, // Pop-up'a hangi sekmenin açılacağını söylüyoruz
          ),
        );

    if (selectedItem != null) {
      setState(() {
        _pendingSubject = selectedItem;
      });
    }
  }

  void _clearPendingSubject() {
    setState(() {
      _pendingSubject = null;
    });
  }

  Future<void> _loadBagItem() async {
    final prefs = await SharedPreferences.getInstance();
    String bagItemsStr = await prefs.getString('bagItemsStr') ?? "";

    setState(() {
      _bagItemsStr = bagItemsStr;
    });
  }

  DateTime _dateKey(DateTime date) => DateTime(date.year, date.month, date.day);

  void _toggleDay(DateTime day) {
    final key = _dateKey(day);
    setState(() {
      if (_selectedDays.contains(key)) {
        _selectedDays.remove(key);
      } else {
        _selectedDays.add(key);
      }
    });
  }

  void _openAddLessons() {
    if (_selectedDays.isEmpty) {
      showDaySelectionEmptyDialog(context);
      return;
    }
    setState(() => _step = _DaySelectionStep.addLessons);
  }

  void _closePage() => Navigator.of(context).pop();

  void _backToCalendar() {
    if (widget.initialSchedule == null) {
      setState(() => _step = _DaySelectionStep.calendar);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onCalendar = _step == _DaySelectionStep.calendar;
    // Akıllı buton kontrolü: Kullanıcı gün seçtiyse buton aktifleşsin
    final hasSelection = _selectedDays.isNotEmpty;

    return PopScope(
      canPop: onCalendar,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!onCalendar) _backToCalendar();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onCalendar)
              DaySelectionTopAppBar(onBack: _closePage, onNext: _openAddLessons)
            else
              AddLessonsTopHeader(
                title: 'Program Detayı',
                onBack: _backToCalendar,
                bagItemsStr: _bagItemsStr ?? "",
                onBagTap: (tabName) => _openBagPopup(tabName),
                pendingSubject: _pendingSubject,
                onFinish: _clearPendingSubject,
              ),
            Expanded(
              child: IndexedStack(
                index: _step.index,
                children: [
                  // BODY TERTEMİZ: Sadece günleri ve tıklamayı yönetiyor, ileri butonuyla ilgilenmiyor
                  DaySelectionBody(
                    selectedDays: _selectedDays,
                    onDayToggled: _toggleDay,
                  ),
                  AddLessonsPage(
                    selectedDays: _selectedDays,
                    bagItemsStr: _bagItemsStr,
                    // BURAYI EKLİYORUZ: Bekleyen konuyu ve temizleme fonksiyonunu Body'e iletiyoruz
                    pendingSubject: _pendingSubject,
                    onSubjectPlaced: _clearPendingSubject,
                    repository: widget.repository,
                    allLessons: widget.allLessons,
                    initialSchedule: widget.initialSchedule,
                  ),
                ],
              ),
            ),
          ],
        ),

        // --- DOĞRU YER BURASI ---
        // Sadece takvim aşamasındaysak sağ altta bu yüksek z-index'li butonu göster
        floatingActionButton: onCalendar
            ? AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasSelection ? 1.0 : 0.5,
                child: FloatingActionButton.extended(
                  onPressed: hasSelection ? _openAddLessons : null,
                  elevation: hasSelection ? 4 : 0,
                  backgroundColor: AppColors.primaryOrange,
                  label: const Row(
                    children: [
                      Text(
                        'İleri',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )
            : null, // Ders ekleme adımına geçince buton otomatik yok olur
      ),
    );
  }
}

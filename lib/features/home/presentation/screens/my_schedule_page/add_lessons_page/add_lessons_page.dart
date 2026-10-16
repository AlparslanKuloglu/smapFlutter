import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/add_lessons_page/widgets/add_lessons_complete_button.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/add_lessons_page/widgets/add_lessons_date_header.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/add_lessons_page/widgets/add_lessons_day_selector.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/add_lessons_page/widgets/add_lessons_timeline_card.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/add_lessons_page/widgets/add_topic_popup.dart';
import 'package:studentmap/repository/weekly_repository.dart';
import 'package:studentmap/core/theme/app_colors.dart';

class AddLessonsPage extends StatefulWidget {
  const AddLessonsPage({
    super.key,
    required this.selectedDays,
    required this.bagItemsStr,
    this.pendingSubject,
    required this.onSubjectPlaced,
    required this.repository,
    required this.allLessons,
    this.initialSchedule,
    this.startHour = 6,
    this.endHour = 23,
    this.intervalMinutes = 60,
  });

  final Set<DateTime> selectedDays;
  final String? bagItemsStr;
  final Map<String, dynamic>? pendingSubject;
  final VoidCallback onSubjectPlaced;
  final WeeklyRepository repository;
  final dynamic allLessons;
  final Map<String, dynamic>? initialSchedule;

  final int startHour;
  final int endHour;
  final int intervalMinutes;

  @override
  State<AddLessonsPage> createState() => _AddLessonsPageState();
}

class _AddLessonsPageState extends State<AddLessonsPage> {
  int _selectedDayIndex = 0;
  bool _isLoading = false;
  final Map<String, List<Map<String, dynamic>>> _selectedLessonsGrid = {};

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  bool _isEditMode = false;

  @override
  void didUpdateWidget(covariant AddLessonsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Üst sayfadan yeni bir pendingSubject setlendiğinde burası tetiklenir
    if (widget.pendingSubject != oldWidget.pendingSubject &&
        widget.pendingSubject != null) {
      setState(() {
        _isEditMode = true;
      });
    }
  }

  final ScrollController _scrollController = ScrollController();
  int _itemsAboveCount = 0;
  int _itemsBelowCount = 0;

  final GlobalKey _viewportKey = GlobalKey();
  final Map<String, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _parseAndLoadInitialSchedule();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _calculateOffscreenItems(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _motivationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateOffscreenItems() {
    if (!_scrollController.hasClients) return;

    final RenderBox? viewportBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewportBox == null) return;

    final double viewportTop = viewportBox.localToGlobal(Offset.zero).dy;
    final double viewportBottom = viewportTop + viewportBox.size.height;

    int above = 0;
    int below = 0;

    final days = _sortedDays;
    if (days.isEmpty || _selectedDayIndex >= days.length) return;
    final currentDayStr = days[_selectedDayIndex].toIso8601String().split(
      'T',
    )[0];

    _cardKeys.forEach((gridKey, key) {
      if (!gridKey.startsWith(currentDayStr)) return;

      final RenderBox? cardBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (cardBox == null) return;

      final double cardTop = cardBox.localToGlobal(Offset.zero).dy;
      final double cardBottom = cardTop + cardBox.size.height;

      final int count = _selectedLessonsGrid[gridKey]?.length ?? 0;

      if (count > 0) {
        if (cardBottom < viewportTop) {
          above += count;
        } else if (cardTop > viewportBottom) {
          below += count;
        }
      }
    });

    if (_itemsAboveCount != above || _itemsBelowCount != below) {
      setState(() {
        _itemsAboveCount = above;
        _itemsBelowCount = below;
      });
    }
  }

  // 🎯 NOKTA ATIŞI: İçinde ders olan EN ÜSTTEKİ elemana odaklanma fonksiyonu
  void _scrollToFirstLessonAbove() {
    final days = _sortedDays;
    if (days.isEmpty) return;
    final currentDayStr = days[_selectedDayIndex].toIso8601String().split(
      'T',
    )[0];
    final timeSlots = _generateTimeSlots();

    for (int i = 0; i < timeSlots.length; i++) {
      final String gridKey = "${currentDayStr}_${timeSlots[i]}";
      final int count = _selectedLessonsGrid[gridKey]?.length ?? 0;

      // Yukarıdan aşağıya tararken içinde ders olan İLK kartı buluyoruz
      if (count > 0) {
        final key = _cardKeys[gridKey];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: 0.5, // Kartı ekranın tam ortasına getirir
          );
          break;
        }
      }
    }
  }

  // 🎯 NOKTA ATIŞI: İçinde ders olan EN ALTAKİ elemana odaklanma fonksiyonu
  void _scrollToLastLessonBelow() {
    final days = _sortedDays;
    if (days.isEmpty) return;
    final currentDayStr = days[_selectedDayIndex].toIso8601String().split(
      'T',
    )[0];
    final timeSlots = _generateTimeSlots();

    // Aşağıdan yukarıya doğru tarayarak içinde ders olan EN ALTAKİ kartı buluyoruz
    for (int i = timeSlots.length - 1; i >= 0; i--) {
      final String gridKey = "${currentDayStr}_${timeSlots[i]}";
      final int count = _selectedLessonsGrid[gridKey]?.length ?? 0;

      if (count > 0) {
        final key = _cardKeys[gridKey];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(
            key!.currentContext!,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            alignment: 0.5, // Kartı ekranın tam ortasına getirir
          );
          break;
        }
      }
    }
  }

  void _parseAndLoadInitialSchedule() {
    if (widget.initialSchedule == null) return;
    _titleController.text = widget.initialSchedule!['name']?.toString() ?? '';
    _motivationController.text =
        widget.initialSchedule!['motto']?.toString() ?? '';

    try {
      final contentRaw = widget.initialSchedule!['content'];
      List<dynamic> tasksList = [];

      if (contentRaw is String) {
        tasksList = jsonDecode(contentRaw) as List<dynamic>? ?? [];
      } else if (contentRaw is List) {
        tasksList = contentRaw;
      }

      for (var task in tasksList) {
        if (task is! Map<String, dynamic>) continue;

        final String? dayStr = task['day']?.toString();
        final int? hour = task['hour'] as int?;
        final int? minute = task['minute'] as int?;

        if (dayStr == null || hour == null || minute == null) continue;

        final String hourStr = hour.toString().padLeft(2, '0');
        final String minuteStr = minute.toString().padLeft(2, '0');
        final String timeKey = "$hourStr:$minuteStr";
        final String gridKey = "${dayStr}_$timeKey";

        final Map<String, dynamic> recreatedSubject = {
          "student": task['student'] ?? widget.initialSchedule!['student'],
          "mainSubject": task['mainSubject'],
          "data": {"name": task['title'] ?? '', "konu": task['subject']},
          "lesson": {
            "_id": task['lesson'],
            "name": task['lessonName'],
            "lessonColor": task['lessonColor'],
            "mapImage": task['mapImage'] != null
                ? "assets/icons/${task['mapImage']}"
                : "",
          },
        };

        if (_selectedLessonsGrid[gridKey] == null) {
          _selectedLessonsGrid[gridKey] = [recreatedSubject];
        } else {
          _selectedLessonsGrid[gridKey]!.add(recreatedSubject);
        }
      }
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _calculateOffscreenItems(),
      );
    } catch (e) {
      debugPrint("Initial schedule content parse error: $e");
    }
  }

  List<String> _generateTimeSlots() {
    final List<String> slots = [];
    int currentHour = widget.startHour;
    int currentMinute = 0;

    while (currentHour < widget.endHour ||
        (currentHour == widget.endHour && currentMinute == 0)) {
      final String hourStr = currentHour.toString().padLeft(2, '0');
      final String minuteStr = currentMinute.toString().padLeft(2, '0');
      slots.add("$hourStr:$minuteStr");

      currentMinute += widget.intervalMinutes;
      if (currentMinute >= 60) {
        currentHour += currentMinute ~/ 60;
        currentMinute = currentMinute % 60;
      }
    }
    return slots;
  }

  List<DateTime> get _sortedDays {
    return widget.selectedDays.toList()..sort();
  }

  void _selectDay(int index) {
    if (_sortedDays.isEmpty) return;
    setState(() => _selectedDayIndex = index.clamp(0, _sortedDays.length - 1));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _calculateOffscreenItems(),
    );
  }

  void _showResetConfirmationDialog() {
    final days = _sortedDays;
    if (days.isEmpty) return;

    final currentDayStr = days[_selectedDayIndex].toIso8601String().split(
      'T',
    )[0];
    final hasLessonsForCurrentDay = _selectedLessonsGrid.keys.any(
      (key) => key.startsWith(currentDayStr),
    );

    if (!hasLessonsForCurrentDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Sıfırlanacak ders girdisi bulunmuyor.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Günü Sıfırla',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: const Text(
            'Bu güne eklediğiniz tüm dersler temizlenecektir. Onaylıyor musunuz?',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedLessonsGrid.removeWhere(
                    (key, value) => key.startsWith(currentDayStr),
                  );
                });
                Navigator.pop(context);
                _calculateOffscreenItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seçili günün programı sıfırlandı.'),
                  ),
                );
              },
              child: const Text(
                'Sıfırla',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openTopicSelectionPopup(String time) async {
    if (_sortedDays.isEmpty) return;

    final Map<String, dynamic>? selectedItem =
        await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => AddTopicPopup(
            bagItemsStr: widget.bagItemsStr,
            initialTab: "bag",
            repository: widget.repository,
          ),
        );

    if (selectedItem != null) {
      final currentDayStr = _sortedDays[_selectedDayIndex]
          .toIso8601String()
          .split('T')[0];
      final String gridKey = "${currentDayStr}_$time";

      setState(() {
        if (_selectedLessonsGrid[gridKey] == null) {
          _selectedLessonsGrid[gridKey] = [selectedItem];
        } else {
          _selectedLessonsGrid[gridKey]!.add(selectedItem);
        }
      });
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _calculateOffscreenItems(),
      );
    }
  }

  void _showSaveDetailsDialog(bool isUpdate) {
    if (_selectedLessonsGrid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Lütfen önce programınıza ders ekleyin.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.grey[900],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Programı Tamamla',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.appBarBackground,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Lütfen programınız için gerekli bilgileri girin.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Program Adı *',
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.appBarBlueGrey,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 1,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Program adı boş bırakılamaz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _motivationController,
                    maxLines: 2,
                    minLines: 1,
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Motivasyon Cümlesi',
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.appBarBlueGrey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Vazgeç',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final scheduleTitle = _titleController.text.trim();
                  final motivationText = _motivationController.text.trim();
                  Navigator.pop(context);
                  if (isUpdate) {
                    final Map<String, dynamic>? activeWeekly =
                        widget.initialSchedule;
                    _submitSchedule(
                      scheduleTitle,
                      motivationText,
                      activeWeekly,
                    );
                  } else {
                    _submitSchedule(scheduleTitle, motivationText, null);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  static String clearHex(dynamic rawColor) {
    if (rawColor == null) return '#000000';
    String colorStr = rawColor.toString().trim();

    if (colorStr.startsWith('#') || !colorStr.contains('Color(')) {
      String cleanHex = colorStr
          .replaceAll('#', '')
          .replaceAll('0x', '')
          .replaceAll('0X', '');
      if (cleanHex.length == 8) cleanHex = cleanHex.substring(2);
      return '#${cleanHex.toUpperCase()}';
    }

    try {
      final rMatch = RegExp(r'red:\s*([0-9.]+)').firstMatch(colorStr);
      final gMatch = RegExp(r'green:\s*([0-9.]+)').firstMatch(colorStr);
      final bMatch = RegExp(r'blue:\s*([0-9.]+)').firstMatch(colorStr);

      if (rMatch != null && gMatch != null && bMatch != null) {
        int r = (double.parse(rMatch.group(1)!) * 255).round().clamp(0, 255);
        int g = (double.parse(gMatch.group(1)!) * 255).round().clamp(0, 255);
        int b = (double.parse(bMatch.group(1)!) * 255).round().clamp(0, 255);

        String rHex = r.toRadixString(16).padLeft(2, '0');
        String gHex = g.toRadixString(16).padLeft(2, '0');
        String bHex = b.toRadixString(16).padLeft(2, '0');

        return '#${(rHex + gHex + bHex).toUpperCase()}';
      }
    } catch (e) {}
    return '#000000';
  }

  void _submitSchedule(
    String programTitle,
    String motivation,
    Map<String, dynamic>? activeWeekly,
  ) async {
    final List<Map<String, dynamic>> tasks = [];

    _selectedLessonsGrid.forEach((gridKey, lessonsList) {
      final parts = gridKey.split('_');
      final String dateStr = parts[0];
      final String timeStr = parts[1];

      final timeParts = timeStr.split(':');
      final int hourInt = int.parse(timeParts[0]);
      final int minuteInt = int.parse(timeParts[1]);

      for (var obj in lessonsList) {
        if (obj is! Map) continue;

        final Map<String, dynamic> currentObj = Map<String, dynamic>.from(obj);
        final dynamic data = currentObj['data'];
        final dynamic lesson = currentObj['lesson'];
        final bool itsBagItem = currentObj['student'] != null;

        String subjectName = "";
        String lessonId = "";
        String mainSubjectId = "";
        String subjectId = "";
        String itemId = "";
        String lessonImage = "";
        String lessonColor = "";
        String lessonName = "";

        if (data != null && data is Map) {
          subjectName = data['name']?.toString() ?? "";
          if (itsBagItem) {
            mainSubjectId = currentObj['mainSubject']?.toString() ?? "";
            subjectId = data['konu']?.toString() ?? "";
            itemId = data['_id']?.toString() ?? "";
          } else {
            mainSubjectId = data['_id']?.toString() ?? "";
          }
        }

        if (lesson != null && lesson is Map) {
          lessonId = lesson['_id']?.toString() ?? "";
          lessonImage = lesson['mapImage']?.toString() ?? "";
          final rawColor = lesson['lessonColor']?.toString();
          lessonColor = clearHex(rawColor);
          lessonName = lesson['name']?.toString() ?? "";
        }

        String iconName = lessonImage.split('/').last;
        final String uniqueId =
            "task-${DateTime.now().millisecondsSinceEpoch}-${StackTrace.current.hashCode}";

        final Map<String, dynamic> dataObj = {
          "id": uniqueId,
          "day": dateStr,
          "hour": hourInt,
          "minute": minuteInt,
          "lesson": lessonId,
          "lessonName": lessonName,
          "mainSubject": mainSubjectId,
          "subject": subjectId,
          "item": itemId,
          "title": subjectName,
          "category": "0",
          "lessonColor": lessonColor,
          "mapImage": iconName,
        };
        tasks.add(dataObj);
      }
    });

    final Map<String, dynamic> finalRequestData = {
      "dataObj": {"name": programTitle, "motto": motivation, "tasks": tasks},
    };

    setState(() => _isLoading = true);

    try {
      final dynamic response;

      if (activeWeekly == null) {
        // 🟢 SIFIRDAN EKLEME (ADD)
        response = await widget.repository.addWeekly(finalRequestData);
      } else {
        // 🔴 GÜNCELLEME (UPDATE)
        String weeklyId = activeWeekly['_id'];
        finalRequestData["dataObj"]["weeklyId"] = weeklyId;
        response = await widget.repository.updateProgram(finalRequestData);
      }

      setState(() => _isLoading = false);

      if (response['success']) {
        _titleController.clear();
        _motivationController.clear();

        setState(() {
          _selectedLessonsGrid.clear();
          _selectedDayIndex = 0;
          _itemsAboveCount = 0;
          _itemsBelowCount = 0;
        });

        final newWeekly =
            response['weekly'] ??
            response['data'] ??
            finalRequestData['dataObj'];

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program başarıyla kaydedildi!')),
          );
          // 🚀 KRİTİK DEĞİŞİKLİK: true yerine taze nesneyi yukarı fırlatıyoruz
          Navigator.pop(context, newWeekly);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt sırasında bir hata oluştu.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Hata oluştu: $e");
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _sortedDays;

    if (days.isEmpty) {
      return const Scaffold(body: Center(child: Text('Lütfen gün seçiniz.')));
    }

    if (_selectedDayIndex >= days.length) {
      _selectedDayIndex = 0;
    }

    final currentDayStr = days[_selectedDayIndex].toIso8601String().split(
      'T',
    )[0];
    final timeSlots = _generateTimeSlots();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AddLessonsDateHeader(
                selectedDays: days,
                onReset: _showResetConfirmationDialog,
                isEditingLocked: widget.initialSchedule != null && !_isEditMode,
              ),
              AddLessonsDaySelector(
                days: days,
                selectedIndex: _selectedDayIndex,
                onSelected: _selectDay,
                onPrevious: _selectedDayIndex > 0
                    ? () => _selectDay(_selectedDayIndex - 1)
                    : null,
                onNext: _selectedDayIndex < days.length - 1
                    ? () => _selectDay(_selectedDayIndex + 1)
                    : null,
              ),
              Expanded(
                key: _viewportKey,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    _calculateOffscreenItems();
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 88),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        children: timeSlots.map((time) {
                          final String gridKey = "${currentDayStr}_$time";
                          final cardKey = _cardKeys.putIfAbsent(
                            gridKey,
                            () => GlobalKey(),
                          );

                          return Padding(
                            key: cardKey,
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildTimelineCard(currentDayStr, time),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // YUKARI OK ROZETİ
          if (_itemsAboveCount > 0)
            Positioned(
              right: 12,
              top: 150,
              child: GestureDetector(
                onTap: _scrollToFirstLessonAbove, // 🎯 Güncellendi
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_itemsAboveCount Ders',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // AŞAĞI OK ROZETİ
          if (_itemsBelowCount > 0)
            Positioned(
              right: 12,
              bottom: 92,
              child: GestureDetector(
                onTap: _scrollToLastLessonBelow, // 🎯 Güncellendi
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_itemsBelowCount Ders',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AddLessonsCompleteButton(
                    isLoading: _isLoading,
                    isInitialSchedule: widget.initialSchedule != null,
                    isEditMode: _isEditMode,
                    onEditPressed: () => setState(() => _isEditMode = true),
                    onSavePressed: (isUpdate) =>
                        _showSaveDetailsDialog(isUpdate),
                    onCancelPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.transparent,
                          title: const Text(
                            'Değişiklikleri İptal Et',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            'Yaptığınız düzenlemeler silinecek ve orijinal programa geri dönülecektir.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Vazgeç',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  widget
                                      .onSubjectPlaced(); // Üst taraftaki pendingSubject'i temizler
                                  _isEditMode = false;
                                  _selectedLessonsGrid.clear();
                                  _parseAndLoadInitialSchedule();
                                });
                              },
                              child: const Text(
                                'Geri Al',
                                style: TextStyle(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(String dayStr, String time) {
    final String gridKey = "${dayStr}_$time";
    final savedSubjects = _selectedLessonsGrid[gridKey] ?? [];
    final bool isPendingMode = widget.pendingSubject != null;

    return AddLessonsTimelineCard(
      time: time,
      subjects: savedSubjects,
      isPendingMode: isPendingMode,
      isEditingLocked: widget.initialSchedule != null && !_isEditMode,
      onTap: () {
        if (isPendingMode) {
          setState(() {
            if (_selectedLessonsGrid[gridKey] == null) {
              _selectedLessonsGrid[gridKey] = [widget.pendingSubject!];
            } else {
              _selectedLessonsGrid[gridKey]!.add(widget.pendingSubject!);
            }
          });
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _calculateOffscreenItems(),
          );
        } else {
          _openTopicSelectionPopup(time);
        }
      },
      allLessons: widget.allLessons,
    );
  }
}

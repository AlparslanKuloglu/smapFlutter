import 'package:flutter/material.dart';
import 'package:studentmap/features/analytics/presentation/models/analytics_filters.dart';
import 'package:studentmap/features/analytics/presentation/models/analytics_general_data.dart';
import 'package:studentmap/repository/analysis_repository.dart';
import 'package:studentmap/features/home/presentation/widgets/app_dialog.dart';

class AnalyticsViewNotifier extends ChangeNotifier {
  final AnalysisRepository _repository;

  AnalyticsViewNotifier(this._repository, {int? initialTabIndex})
    : _state = AnalyticsViewState.initial(
        generalData: AnalyticsGeneralData.empty(),
        initialTabIndex: initialTabIndex, // State'e ilk index'i pasladık
      ) {
    loadAllData();
  }

  AnalyticsViewState _state;
  AnalyticsViewState get state => _state;

  Future<void> loadAllData() async {
    try {
      final totalResponse = await _repository.getTotal(
        type: state.examType.value.toString(),
        lesson: state.selectedLesson == 'Genel' || state.selectedLesson.isEmpty
            ? null
            : state.selectedLesson,
        selectedAimType: state.selectedAimType,
      );

      final chartResponse = await _repository.getLineChartData(
        type: state.examType.value.toString(),
        lesson: state.selectedLesson == 'Genel' || state.selectedLesson.isEmpty
            ? null
            : state.selectedLesson,
        selectedAimType: state.selectedAimType,
      );
      final apiUserData = chartResponse['user'] as Map<String, dynamic>? ?? {};

      if (state.userData.isEmpty && apiUserData.isNotEmpty) {
        //final int aimType = apiUserData['aimType']; // todosmap, backend düzeltme.
        final int aimType = 2;
        if (aimType >= 2) {
          final matchedAytGroup = AytGroup.values.firstWhere(
            (e) => e.value == aimType,
            orElse: () => AytGroup.esitAgirlik, // Bulamazsa default
          );

          _updateState(
            state.copyWith(aytGroup: matchedAytGroup, selectedAimType: aimType),
          );
        }
        _updateState(state.copyWith(userData: apiUserData));
      }

      final newGeneralData = _mapToGeneralData(totalResponse, chartResponse);

      _updateState(state.copyWith(generalData: newGeneralData));
    } catch (e) {
      debugPrint("Veri yükleme hatası: $e");
    }
  }

  Future<void> getMyMockExams({bool isRefresh = false}) async {
    // Eğer refresh yapılıyorsa sayfa 1'e döner, aksi halde mevcut sayfa üzerinden devam eder.
    if (isRefresh) {
      _updateState(state.copyWith(page: 1, hasMore: true, myMockExams: []));
    }

    // Veri yükleniyorsa veya başka veri yoksa isteği durdur.
    if (state.isLoadingMore || !state.hasMore) return;

    _updateState(state.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.getMyMockExams(page: state.page);
      final List<dynamic> newExams =
          response['enrichedMockExams'] ?? []; // API yapına göre düzenle

      // Veri bitti mi kontrolü
      final bool canLoadMore =
          newExams.length >= 8; // Sayfa başı 10 veri geliyorsa

      _updateState(
        state.copyWith(
          myMockExams: [
            ...state.myMockExams,
            ...newExams,
          ], // Eski + Yeni veriler
          page: state.page + 1,
          isLoadingMore: false,
          hasMore: canLoadMore,
        ),
      );
    } catch (e) {
      _updateState(state.copyWith(isLoadingMore: false));
    }
  }

  void onTopTabTap(int index, BuildContext context) {
    // <-- BuildContext eklendi
    if (index == 0) {
      final wasOnGeneral = state.topTabIndex == 0;
      // Zaten Genel sekmesindeyse paneli toggle et, ilk defa geçiliyorsa kapalı tut (false)
      final open = wasOnGeneral ? !state.generalFilterOpen : false;
      _updateState(state.copyWith(topTabIndex: index, generalFilterOpen: open));
    } else if (index == 1) {
      _updateState(state.copyWith(topTabIndex: index));
    } else if (index == 2) {
      AppDialogs.showUnderConstruction(
        context,
        title: "Analiz",
        imagePath: "",
        desc:
            "Güçlü ve zayıf konularını takip edebileceğin ve karşılaşma ve doğru/yanlış/boş istatistiklerini görebileceğin analiz ekranı.\n\n Çok yakında hazır.",
      );
    } else {
      AppDialogs.showUnderConstruction(
        context,
        title: "Kavram Haritan",
        imagePath: "",
        desc:
            "Matematik ve Geometri'deki durumunu görsel olarak takip edebileceğin bu modül mobilde de çok yakında kullanılabilecek. \n\n Web kısmında ise şu anda hazır. smaptr.com'dan giriş yaparak kavram haritanı görebilirsin",
      );
    }
  }

  AnalyticsGeneralData _mapToGeneralData(
    Map<String, dynamic> totalResponse,
    Map<String, dynamic> chartResponse,
  ) {
    final totalData = totalResponse['total'] as Map<String, dynamic>? ?? {};
    final List<dynamic> lessonItems =
        totalResponse['items'] as List<dynamic>? ?? [];

    final List<dynamic> examList = chartResponse['mockexams'] as List? ?? [];

    final List<NetGraphPoint> points = examList.map((exam) {
      return NetGraphPoint(value: (exam['net'] as num? ?? 0).toDouble());
    }).toList();

    final List<String> dates = examList.map((exam) {
      final String dateStr = exam['date'] ?? '';
      if (dateStr.length >= 10) {
        final parts = dateStr.substring(0, 10).split('-');
        return '${parts[2]}/${parts[1]}';
      }
      return dateStr;
    }).toList();

    double totalRanking = 0;
    double totalScore = 0;
    int rankingCount = 0;
    int scoreCount = 0;
    int totalQuestion = state.examType == ExamType.tyt ? 120 : 80;
    int totalTrue = 0;
    int totalPass = 0;
    int totalWrong = 0;
    double totalNet = 0.0;
    double averageNet = 0.0;

    final List<AnalyticsLessonDistributionData> distributions = [];

    final responseTotalQuestion = chartResponse['totalQuestion'];
    if (responseTotalQuestion != null) {
      totalQuestion = (responseTotalQuestion as num).toInt();
      for (int i = 0; i < lessonItems.length; i++) {
        final lessonItem = lessonItems[i];
        final String subjectName = lessonItem['subject']?['name'] ?? '';
        int value = (lessonItem['count'] ?? 0) - (lessonItem['trueValue'] ?? 0);
        if (value > 0) {
          distributions.add(
            AnalyticsLessonDistributionData(
              lesson: subjectName,
              value: value.toDouble(),
              color: _getThemeColor(i),
            ),
          );
        }
      }
    }

    final List<String> subjects = List<String>.from(
      totalData['lessOrSubjects'] ?? [],
    );
    final List<dynamic> values = totalData['data'] ?? [];

    for (int i = 0; i < subjects.length; i++) {
      distributions.add(
        AnalyticsLessonDistributionData(
          lesson: subjects[i],
          value: i < values.length ? (values[i] as num).toDouble() : 0.0,
          color: _getThemeColor(i),
        ),
      );
    }

    for (var exam in examList) {
      final List<dynamic>? ranks = exam['ranks'] as List?;
      final List<dynamic>? scores = exam['points'] as List?;

      if (responseTotalQuestion != null) {
        totalTrue += (exam['true'] as num? ?? 0).toInt();
        totalPass += (exam['pass'] as num? ?? 0).toInt();
        totalWrong += (exam['wrong'] as num? ?? 0).toInt();
        totalNet += (exam['net'] as num? ?? 0.0).toDouble();
      }

      // TYT ise 0. index (Genel), AYT ise enum'dan gelen value (id) kullanılıyor
      int targetIndex = state.examType == ExamType.tyt
          ? 0
          : state.aytGroup.value;

      if (ranks != null && targetIndex < ranks.length) {
        final rawRank = ranks[targetIndex];
        if (rawRank != null && rawRank.toString().isNotEmpty) {
          String cleanRank = rawRank
              .toString()
              .replaceAll('.', '')
              .replaceAll(',', '');
          double? val = double.tryParse(cleanRank);
          if (val != null) {
            totalRanking += val;
            rankingCount++;
          }
        }
      }
      if (scores != null && targetIndex < scores.length) {
        final rawPoint = scores[targetIndex];
        if (rawPoint != null && rawPoint.toString().isNotEmpty) {
          String cleanPoint = rawPoint.toString().replaceAll(',', '.');
          double? val = double.tryParse(cleanPoint);
          if (val != null) {
            totalScore += val;
            scoreCount++;
          }
        }
      }
    }

    averageNet = examList.isNotEmpty ? totalNet / examList.length : 0.0;

    String avgRankingFormatted = '-';
    if (rankingCount > 0) {
      int avgRank = (totalRanking / rankingCount).round();
      avgRankingFormatted = avgRank.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }

    final List<AnalyticsMetricCardData> metricCards;
    if (state.selectedLessonName == "Genel" ||
        state.selectedLessonName == null) {
      metricCards = [
        AnalyticsMetricCardData(
          value: (totalData['count'] ?? 0).toString(),
          label: 'Çözülen Deneme',
          iconPath: "assets/svgs/bookr212.svg",
        ),
        AnalyticsMetricCardData(
          value: (totalData['ortNet'] ?? 0).toStringAsFixed(2),
          label: 'Ortalama Net',
          iconPath: "assets/svgs/correct.svg",
        ),
        AnalyticsMetricCardData(
          value: avgRankingFormatted,
          label: 'Ort. Sıralama',
          iconPath: "assets/svgs/rank.svg",
        ),
        AnalyticsMetricCardData(
          value: scoreCount > 0
              ? (totalScore / scoreCount).toStringAsFixed(2)
              : '-',
          label: 'Ortalama Puan',
          iconPath: "assets/svgs/point.svg",
        ),
      ];
    } else {
      metricCards = [
        AnalyticsMetricCardData(
          value: totalTrue.toString(),
          label: 'Toplam Doğru',
          iconPath: "assets/svgs/rank.svg",
        ),
        AnalyticsMetricCardData(
          value: averageNet.toStringAsFixed(2),
          label: 'Ortalama Net',
          iconPath: "assets/svgs/correct.svg",
        ),
        AnalyticsMetricCardData(
          value: totalWrong.toString(),
          label: 'Toplam Yanlış',
          iconPath: "assets/svgs/wrong.svg",
        ),
        AnalyticsMetricCardData(
          value: totalPass.toString(),
          label: 'Toplam Boş',
          iconPath: "assets/svgs/pass.svg",
        ),
      ];
    }

    return AnalyticsGeneralData(
      chart: AnalyticsChartData(
        title: 'Deneme Net Grafiği',
        subtitle:
            '${state.examType == ExamType.tyt ? 'TYT' : state.aytGroup.label} ${state.selectedLessonName}',
        primaryColor: const Color(0xFF1E344A),
        yLabels: getYLabels(totalQuestion),
        xLabels: dates.isEmpty ? ['Veri Yok'] : dates,
        primarySeries: points,
      ),
      cards: metricCards,
      lessonDistributions: distributions,
    );
  }

  Color _getThemeColor(int index) {
    const colors = [
      Color(0xFF3E516A),
      Color(0xFFF68A3F),
      Color(0xFF1D3B5E),
      Color(0xFFF7B889),
      Color(0xFF98A4B2),
      Color(0xFFFF6D00),
      Color(0xFFB0B7C0),
      Color(0xFF4A90E2),
    ];
    return colors[index % colors.length];
  }

  List<String> getYLabels(int totalQuestion) {
    final Map<int, int> intervalRules = {
      120: 30,
      80: 20,
      40: 5,
      30: 5,
      24: 4,
      5: 1,
      6: 1,
      7: 1,
    };
    int interval = intervalRules[totalQuestion] ?? 10;
    List<String> result = [];
    int current = totalQuestion;
    while (current >= 0) {
      result.add(current.toString());
      current -= interval;
      if (current < 0 && !result.contains('0')) result.add('0');
    }
    return result;
  }

  void closeGeneralFilter() =>
      _updateState(state.copyWith(generalFilterOpen: false));

  void setExamType(ExamType examType) {
    _updateState(
      state.copyWith(
        examType: examType,
        // Direkt enum tipini kontrol ediyoruz
        selectedAimType: (examType == ExamType.tyt) ? 0 : state.selectedAimType,
      ),
    );
  }

  void setAytGroup(AytGroup aytGroup) {
    _updateState(
      state.copyWith(
        aytGroup: aytGroup,
        selectedAimType: aytGroup.value,
        selectedLessonName: "Genel",
      ),
    );
    loadAllData();
  }

  void setLesson(String id, String name) {
    _updateState(
      state.copyWith(
        selectedLesson: id,
        selectedLessonName: name,
        generalFilterOpen: false,
      ),
    );
    loadAllData();
  }

  void _updateState(AnalyticsViewState newState) {
    _state = newState;
    notifyListeners();
  }

  // Statik build metodunu da yeni enum yapısına göre güncelledim
  static AnalyticsGeneralData _buildGeneralData({
    required ExamType examType,
    required AytGroup aytGroup,
    required String selectedLesson,
  }) {
    final scope = examType == ExamType.tyt ? 'TYT' : 'AYT - ${aytGroup.label}';
    final base = selectedLesson.runes.fold<int>(0, (sum, rune) => sum + rune);
    final series = List<NetGraphPoint>.generate(15, (index) {
      final value = 20 + ((base + (index * 9)) % 36);
      return NetGraphPoint(value: value.toDouble());
    });

    final avgNet =
        (series.map((e) => e.value).reduce((a, b) => a + b) / series.length)
            .round();

    return AnalyticsGeneralData(
      chart: AnalyticsChartData(
        title: 'Deneme Net Grafiği',
        subtitle: '$scope $selectedLesson',
        primaryColor: const Color(0xFF1E344A),
        yLabels: const ['120', '90', '60', '30', '0'],
        xLabels: const ['Veri Yok'],
        primarySeries: series,
      ),
      cards: [
        AnalyticsMetricCardData(
          value: '$avgNet',
          label: 'Ortalama Net',
          iconPath: "",
        ),
        AnalyticsMetricCardData(
          value: '${95 + (base % 20)}',
          label: 'Ortalama Puan',
          iconPath: "",
        ),
        AnalyticsMetricCardData(
          value: '${140 + (base % 30)}',
          label: 'Ort. Siralama',
          iconPath: "",
        ),
        AnalyticsMetricCardData(
          value: '${110 + (base % 20)}',
          label: 'Toplam Dogru',
          iconPath: "",
        ),
      ],
      lessonDistributions: [],
    );
  }
}

class AnalyticsViewState {
  const AnalyticsViewState({
    required this.topTabIndex,
    required this.generalFilterOpen,
    required this.examType,
    required this.aytGroup,
    required this.selectedLesson,
    required this.generalData,
    required this.selectedAimType,
    required this.selectedLessonName,
    required this.page,
    required this.myMockExams,
    required this.isLoadingMore,
    required this.hasMore,
    required this.userData, // JSON olarak tutuyoruz
  });

  factory AnalyticsViewState.initial({
    required AnalyticsGeneralData generalData,
    int? initialTabIndex,
  }) {
    return AnalyticsViewState(
      topTabIndex: initialTabIndex ?? 0,
      generalFilterOpen: false,
      examType: ExamType.tyt,
      aytGroup: AytGroup.esitAgirlik,
      selectedLesson: 'geneltyt', //
      selectedLessonName: "Genel",
      generalData: generalData,
      selectedAimType: 0,
      page: 1,
      myMockExams: const [],
      isLoadingMore: false,
      hasMore: true,
      userData: const {}, // Başlangıçta boş bir Map
    );
  }

  final int topTabIndex;
  final bool generalFilterOpen;
  final ExamType examType;
  final AytGroup aytGroup;
  final String selectedLesson;
  final String selectedLessonName;
  final int selectedAimType;
  final AnalyticsGeneralData generalData;
  final int page;
  final List<dynamic> myMockExams;
  final bool isLoadingMore;
  final bool hasMore;
  final Map<String, dynamic> userData; // SharedPreferences'tan gelen JSON Map

  AnalyticsViewState copyWith({
    int? topTabIndex,
    bool? generalFilterOpen,
    ExamType? examType,
    AytGroup? aytGroup,
    String? selectedLesson,
    String? selectedLessonName,
    int? selectedAimType,
    AnalyticsGeneralData? generalData,
    int? page,
    List<dynamic>? myMockExams,
    bool? isLoadingMore,
    bool? hasMore,
    Map<String, dynamic>? userData,
  }) {
    return AnalyticsViewState(
      topTabIndex: topTabIndex ?? this.topTabIndex,
      generalFilterOpen: generalFilterOpen ?? this.generalFilterOpen,
      examType: examType ?? this.examType,
      aytGroup: aytGroup ?? this.aytGroup,
      selectedLesson: selectedLesson ?? this.selectedLesson,
      selectedLessonName: selectedLessonName ?? this.selectedLessonName,
      generalData: generalData ?? this.generalData,
      selectedAimType: selectedAimType ?? this.selectedAimType,
      page: page ?? this.page,
      myMockExams: myMockExams ?? this.myMockExams,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      userData: userData ?? this.userData,
    );
  }
}

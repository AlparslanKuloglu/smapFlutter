import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studentmap/domain/models/general_lessons.dart';
import 'package:studentmap/core/constants/lesson_constants.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/repository/analysis_repository.dart';

class SubTopicDetailPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final int tabFilterValue;

  const SubTopicDetailPage({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.tabFilterValue,
  });

  @override
  State<SubTopicDetailPage> createState() => _SubTopicDetailPageState();
}

class _SubTopicDetailPageState extends State<SubTopicDetailPage> {
  bool _isLoading = true;
  List<dynamic> _subTopics = [];
  late final AnalysisRepository _analysisRepository;
  @override
  void initState() {
    super.initState();
    _analysisRepository = AnalysisRepository();
    _fetchSubTopics();
  }

  Future<void> _fetchSubTopics() async {
    setState(() => _isLoading = true);

    try {
      final response = await _analysisRepository.getSubSubjectsAndItems(
        mainSubjectId: widget.topicId,
        type: widget.tabFilterValue,
      );

      List<dynamic> mappedData = [];

      if (response != null && response['success'] == true) {
        final List<dynamic> subSubjects = response['subSubjects'] ?? [];
        final List<dynamic> itemsArray = response['itemsArray'] ?? [];

        for (int i = 0; i < subSubjects.length; i++) {
          final subSubjectItem = subSubjects[i] as Map<String, dynamic>;
          final String subSubjectId = subSubjectItem['_id']?.toString() ?? '';
          final String subSubjectName =
              subSubjectItem['name']?.toString() ?? 'Alt Başlık';

          final String image = subSubjectItem['image'];
          final String imageColor = subSubjectItem['imageColor'];
          final String barColor = subSubjectItem['barColor'];

          List<dynamic> correspondingItems = [];
          if (itemsArray.length > i && itemsArray[i] is List) {
            correspondingItems = itemsArray[i];
          }

          mappedData.add({
            "_id": subSubjectId,
            "title": subSubjectName,
            "image": image,
            "imageColor": imageColor,
            "barColor": barColor,
            "items": correspondingItems,
          });
        }
      }

      setState(() {
        _subTopics = mappedData;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstAlertCard();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Alt konular işlenirken hata oluştu: $e");
    }
  }

  void _scrollToFirstAlertCard() {
    try {
      // 1. Uyarılı olan İLK kartı buluyoruz
      final firstAlertCategory = _subTopics.firstWhere((category) {
        final List<dynamic> items = category['items'] as List<dynamic>? ?? [];

        return items.any((itemData) {
          final Map<String, dynamic> item =
              itemData as Map<String, dynamic>? ?? {};
          final Map<String, dynamic> nestedItemData =
              item['itemData'] as Map<String, dynamic>? ?? {};

          // 1. Şart: saltStatusIs0 doğru mu?
          final bool saltStatusIs0 = nestedItemData['status'] == 0;

          // 2. Şart: statusArray içinde "0" var mı?
          final List<dynamic> statusList =
              nestedItemData['statusArray'] as List<dynamic>? ?? [];
          final bool hasZeroInArray = statusList.any(
            (status) => status.toString() == "0",
          );

          // İkisinden biri true ise bu item uyarılıdır, any() fonksiyonu true döner.
          return saltStatusIs0 || hasZeroInArray;
        });
      }, orElse: () => null);

      if (firstAlertCategory != null) {
        // 2. ADIM: Bulunan bu kartın ana listedeki index'ini kontrol ediyoruz
        final int targetIndex = _subTopics.indexOf(firstAlertCategory);

        // Eğer uyarılı ilk kart zaten en baştaki (0. index) kart ise KAYDIRMA YAPMA!
        if (targetIndex == 0) {
          debugPrint(
            "Uyarılı kart ilk sırada olduğu için kaydırma iptal edildi.",
          );
          return;
        }

        // 3. ADIM: İlk sırada değilse (aşağılardaysa) güvenli bir şekilde kaydırıyoruz
        final GlobalKey? targetKey =
            firstAlertCategory['cardKey'] as GlobalKey?;
        if (targetKey != null && targetKey.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.0,
          );
        }
      }
    } catch (e) {
      debugPrint("Otomatik kaydırma sırasında hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuCardBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCustomHeader(context, widget.topicName),
                Expanded(
                  child: _subTopics.isEmpty
                      ? const Center(
                          child: Text("Bu konuya ait alt başlık bulunamadı."),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowLight,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (
                                  int parentIndex = 0;
                                  parentIndex < _subTopics.length;
                                  parentIndex++
                                ) ...[
                                  if (parentIndex > 0)
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.unselectedGrey,
                                    ),
                                  Builder(
                                    builder: (context) {
                                      final parentCategory =
                                          _subTopics[parentIndex]
                                              as Map<String, dynamic>;
                                      final String categoryTitle =
                                          parentCategory['title'] as String? ??
                                          '';
                                      final List<dynamic> items =
                                          parentCategory['items']
                                              as List<dynamic>? ??
                                          [];
                                      final GlobalKey cardKey = GlobalKey();
                                      parentCategory['cardKey'] = cardKey;

                                      final String? image =
                                          parentCategory['image'];
                                      final Color imageColor =
                                          AppColors.hexToColor(
                                            parentCategory['imageColor'],
                                          );
                                      final Color barColor =
                                          AppColors.hexToColor(
                                            parentCategory['barColor'],
                                          );

                                      return _MainTopicExpansionCard(
                                        categoryTitle: categoryTitle,
                                        items: items,
                                        cardKey: cardKey,
                                        itemIndex: parentIndex,
                                        image: image,
                                        imageColor: imageColor,
                                        barColor: barColor,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, String lessonName) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                lessonName,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Opacity(
            opacity: 0,
            child: IconButton(
              onPressed: null,
              icon: Icon(Icons.arrow_back_ios),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainTopicExpansionCard extends StatefulWidget {
  final String categoryTitle;
  final List<dynamic> items;
  final GlobalKey cardKey; // Konumu yakalamak için key ekledik
  final int itemIndex;
  final String? image;
  final Color imageColor;
  final Color barColor;

  static const double _placeholderProgress = 0.6;

  const _MainTopicExpansionCard({
    required this.categoryTitle,
    required this.items,
    required this.cardKey, // Zorunlu hale getirdik
    required this.itemIndex,
    required this.image,
    required this.imageColor,
    required this.barColor,
  });

  @override
  State<_MainTopicExpansionCard> createState() =>
      _MainTopicExpansionCardState();
}

class _MainTopicExpansionCardState extends State<_MainTopicExpansionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = _hasAnyChildAlert() || widget.itemIndex == 0;
  }

  bool _hasAnyChildAlert() {
    return widget.items.any((itemData) {
      final Map<String, dynamic> item = itemData as Map<String, dynamic>? ?? {};
      final Map<String, dynamic> nestedItemData =
          item['itemData'] as Map<String, dynamic>? ?? {};
      final List<dynamic> statusList =
          nestedItemData['statusArray'] as List<dynamic>? ?? [];
      final bool saltStatusIs0 = nestedItemData['status'] == 0;
      final bool hasZeroInArray = statusList.any(
        (status) => status.toString() == "0",
      );
      return saltStatusIs0 || hasZeroInArray;
    });
  }

  @override
  Widget build(BuildContext context) {
    const String _imageBaseUrl = 'https://smaptr.com/subjectIcons/';

    String? subjectImage = widget.image;

    final String fullImageUrl =
        (subjectImage != null && subjectImage.isNotEmpty)
        ? '$_imageBaseUrl$subjectImage'
        : '';
    const double dividerThickness = 1.2;
    const double dividerHeight = 16.0;

    int totalCards = 0;
    int goodCount = 0;
    int alertCount = 0;
    bool hasAnyChildAlert = false;

    for (final itemData in widget.items) {
      final Map<String, dynamic> item = itemData as Map<String, dynamic>? ?? {};
      final Map<String, dynamic> nestedItemData =
          item['itemData'] as Map<String, dynamic>? ?? {};
      final List<dynamic> statusList =
          nestedItemData['statusArray'] as List<dynamic>? ?? [];
      final bool saltStatusIs0 = nestedItemData['status'] == 0;
      final bool hasZeroInArray = statusList.any(
        (status) => status.toString() == "0",
      );

      if (saltStatusIs0 || hasZeroInArray) {
        hasAnyChildAlert = true;
      }

      for (final status in statusList) {
        totalCards++;
        if (status.toString() == "1") {
          goodCount++;
        } else if (status.toString() == "0") {
          alertCount++;
        }
      }
    }

    final Color mainTitleColor = hasAnyChildAlert
        ? AppColors.appBarBackground
        : AppColors.textPrimary;
    final int progressPercent =
        (_MainTopicExpansionCard._placeholderProgress * 100).round();

    return Container(
      key: widget.cardKey,
      color: AppColors.white,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          childrenPadding: const EdgeInsets.only(
            left: 14,
            right: 14,
            bottom: 8,
          ),
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          trailing: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.menuCardBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isExpanded
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 13,
              color: AppColors.appBarBackground,
            ),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categoryTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: mainTitleColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: SizedBox(
                              height: 9,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  const ColoredBox(
                                    color: AppColors.unselectedGrey,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: _MainTopicExpansionCard
                                          ._placeholderProgress,
                                      heightFactor: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              widget.barColor,
                                              widget.barColor.withValues(
                                                alpha: 0.45,
                                              ),
                                            ],
                                            stops: const [0.1, 1.0],
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(24),
                                            bottomRight: Radius.circular(24),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '%$progressPercent',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          iconAsset: 'assets/icons/information_card_gray.svg',
                          value: '$totalCards',
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          iconAsset: 'assets/icons/information_card_green.svg',
                          value: '$goodCount',
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          iconAsset: 'assets/icons/information_card_red.svg',
                          value: '$alertCount',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: widget.imageColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(6),
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.contain,
                        // Görsel yüklenirken gösterilecek widget (Loading)
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        // İnternet olmaması veya 404 hatasında gösterilecek yedek ikon/resim
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 32,
                          );
                        },
                      )
                    // fullImageUrl tamamen boş gelirse gösterilecek varsayılan yerel ikon
                    : Image.asset(
                        'assets/icons/subjecticon.png',
                        fit: BoxFit.contain,
                      ),
              ),
            ],
          ),
          children: [
            Divider(
              height: dividerHeight,
              thickness: dividerThickness,
              color: AppColors.unselectedGrey.withValues(alpha: 0.5),
            ),
            Column(
              children: widget.items.asMap().entries.map((entry) {
                final int itemIndex = entry.key;
                final Map<String, dynamic> item =
                    entry.value as Map<String, dynamic>;
                final String itemName = item['name'] as String? ?? '';
                final List<dynamic> descList =
                    item['desc'] as List<dynamic>? ?? [];

                final Map<String, dynamic> nestedItemData =
                    item['itemData'] as Map<String, dynamic>? ?? {};
                final List<dynamic> promptsList =
                    nestedItemData['prompts'] as List<dynamic>? ?? [];
                final List<dynamic> statusList =
                    nestedItemData['statusArray'] as List<dynamic>? ?? [];

                final int itsIndependent =
                    (item['itemData']?['itsIndependent'] as num?)?.toInt() ?? 0;
                final bool saltStatusIs0 = nestedItemData['status'] == 0;

                final bool hasTitleAlert =
                    statusList.contains(0) || saltStatusIs0;

                return _SubTopicItemTile(
                  itemName: itemName,
                  descList: descList,
                  prompts: promptsList,
                  statusArray: statusList,
                  mainCategoryTitle: widget.categoryTitle,
                  itsIndependent: itsIndependent,
                  saltStatusIs0: saltStatusIs0,
                  itemIndex: itemIndex,
                  titleAlert: hasTitleAlert,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({required String iconAsset, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(iconAsset, width: 16, height: 16),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SubTopicItemTile extends StatefulWidget {
  final String itemName;
  final List<dynamic> descList;
  final List<dynamic> prompts;
  final List<dynamic> statusArray;
  final String mainCategoryTitle;
  final int itsIndependent; // Bağımsızlık durumunu yakalamak için alan ekledik
  final bool saltStatusIs0;
  final int itemIndex;
  final bool titleAlert;

  const _SubTopicItemTile({
    required this.itemName,
    required this.descList,
    required this.prompts,
    required this.statusArray,
    required this.mainCategoryTitle,
    required this.itsIndependent, // Constructor'da zorunlu hale getirdik
    required this.saltStatusIs0,
    required this.itemIndex,
    required this.titleAlert,
  });

  @override
  State<_SubTopicItemTile> createState() => _SubTopicItemTileState();
}

class _SubTopicItemTileState extends State<_SubTopicItemTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.titleAlert;
  }

  // Pop-up detay fonksiyonunu buraya temsili ekliyorum, kendi kodundakiyle eşleşir.
  void _handleDetailTap(Map<String, dynamic> data) {
    final ScrollController popupScrollController = ScrollController();
    // Eğer favori durumu prompt verisinde varsa oradan okusun, yoksa false başlasın
    bool isCardFavorite = data['isFavorite'] as bool? ?? false;

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
                  color: AppColors.white,
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
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['title']?.toUpperCase() ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
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
                            // Ana sayfada bir state tutuluyorsa güncellenebilir
                          },
                        ),
                      ],
                    ),
                    const Divider(
                      height: 24,
                      color: AppColors.menuCardBackground,
                    ),
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 24,
                      color: AppColors.menuCardBackground,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.menuCardBackground,
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
                            color: AppColors.textPrimary,
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
    final Color titleColor = widget.titleAlert
        ? Colors.red
        : AppColors.textPrimary;

    final String iconImage = widget.titleAlert
        ? 'assets/icons/w.png'
        : 'assets/icons/q2.png';

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        // Alt Başlık
        initiallyExpanded: widget.titleAlert, // titleAlert true ise açık gelsin
        tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
        shape: const Border(),
        collapsedShape: const Border(),
        onExpansionChanged: (bool expanded) {
          setState(() => _isExpanded = expanded);
        },
        trailing: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.menuCardBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isExpanded
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 13,
            color: titleColor,
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              iconImage,
              width: 22,
              height: 22,
              fit: BoxFit.contain, // Görselin oranını korumak için
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.descList.map((desc) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2.8, left: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "- ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            desc.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (widget.itsIndependent != 1 &&
                    widget.prompts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _buildStatusCards(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusCards() {
    return widget.prompts.asMap().entries.map((entry) {
      final int index = entry.key;
      final Map<String, dynamic> prompt =
          entry.value as Map<String, dynamic>? ?? {};

      final bool hasAlert = widget.statusArray.length > index
          ? widget.statusArray[index].toString() == "0"
          : false;

      return _StatusInfoCard(
        hasAlert: hasAlert,
        onTap: () {
          _handleDetailTap({
            'subtitle': prompt['title'] ?? 'Bilgi Kartı',
            'title': widget.mainCategoryTitle.toUpperCase(),
            'content':
                prompt['content'] ?? prompt['text'] ?? 'İçerik bulunamadı.',
            'isFavorite': prompt['isFavorite'] ?? false,
          });
        },
      );
    }).toList();
  }
}

class _StatusInfoCard extends StatelessWidget {
  final bool hasAlert;
  final VoidCallback onTap; // Tıklama fonksiyonunu dışarıdan alıyoruz
  const _StatusInfoCard({required this.hasAlert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SvgPicture.asset(
        hasAlert
            ? 'assets/icons/information_card_with_border_red.svg'
            : 'assets/icons/information_card_with_border_green.svg',
        width: 32,
        height: 32,
      ),
    );
  }
}

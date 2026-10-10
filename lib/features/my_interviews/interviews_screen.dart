import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // HomeProvider'ı okumak için eklendi
import 'package:smap/core/theme/app_colors.dart';
// Kendi projenizdeki HomeProvider path'ini buraya ekleyin
import 'package:smap/features/home/presentation/provider/home_provider.dart';
import 'interview_card.dart';
import 'interview_detail_screen.dart';
import 'package:smap/repository/coach_repository.dart';
import 'package:intl/intl.dart'; // Eğer yüklüyse en tepede import et
import 'package:intl/date_symbol_data_local.dart'; // Türkçe lokalizasyon için

class GorusmeFlowScreen extends StatefulWidget {
  const GorusmeFlowScreen({super.key});

  @override
  State<GorusmeFlowScreen> createState() => _GorusmeFlowScreenState();
}

class _GorusmeFlowScreenState extends State<GorusmeFlowScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final CoachRepository repository = CoachRepository();

  List<Map<String, dynamic>> _interviews = [];
  int _page = 1;
  final int _limit = 8;
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchInterviews();
    _scrollController.addListener(_onScroll);
  }

  List<Map<String, dynamic>> _formatInterviews(dynamic responseData) {
    List<dynamic> rawList = [];
    if (responseData is Map && responseData.containsKey('interviews')) {
      rawList = responseData['interviews'] as List<dynamic>;
    } else if (responseData is List) {
      rawList = responseData;
    }

    // Tarihleri Türkçe formatlamak için yerel ayarları initialize etmeliyiz
    initializeDateFormatting('tr_TR', null);

    return rawList.map((item) {
      final mapItem = Map<String, dynamic>.from(item as Map);
      final student = mapItem['student'] is Map
          ? Map<String, dynamic>.from(mapItem['student'] as Map)
          : null;

      // Tarih Dönüşümü:
      String formattedDate = '';
      if (mapItem['date'] != null) {
        try {
          // "2026-06-28T..." string'ini DateTime nesnesine parse ediyoruz
          DateTime parsedDate = DateTime.parse(mapItem['date'].toString());
          // 'd MMMM' formatı -> Gün ve Uzun Ay İsmi verir (Örn: 28 Haziran)
          formattedDate = DateFormat('d MMMM', 'tr_TR').format(parsedDate);
        } catch (e) {
          formattedDate = mapItem['date'].toString(); // Hata durumunda fallback
        }
      }

      return {
        'id': mapItem['_id']?.toString() ?? '',
        'studentName': student != null
            ? '${student['firstName'] ?? ''} ${student['surname'] ?? ''}'.trim()
            : 'Bilinmeyen Öğrenci',
        'studentImage': student != null ? (student['photo'] ?? '') : '',
        'topic': mapItem['type'] == 1 ? 'Öğrenci Görüşmesi' : 'Veli Görüşmesi',
        'date': formattedDate, // "28 Haziran" olarak UI'a gidecek
        'notes': mapItem['notesStr'] ?? '',
      };
    }).toList();
  }

  // State içinde filtre değerlerini tuttuğunu varsayalım
  List<int> _selectedTypes = []; // Örn: Sayfada tip seçildiyse doldurulur
  List<String> _selectedDates =
      []; // Örn: Takvimden tarih seçildiyse doldurulur

  Future<void> _fetchInterviews({bool isRefresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _page = 1;
        _interviews.clear();
        _hasMore = true;
      }
    });

    try {
      // Repository'e POST gövdesini oluşturacak listeleri gönderiyoruz
      final dynamic rawData = await repository.getInterviews(
        page: _page,
        limit: _limit,
        types: _selectedTypes,
        dates: _selectedDates,
      );

      // Bir önceki adımda yazdığımız formatlayıcı fonksiyon (Aynen kalıyor)
      final List<Map<String, dynamic>> newInterviews = _formatInterviews(
        rawData,
      );

      setState(() {
        _isLoading = false;
        if (newInterviews.length < _limit) {
          _hasMore = false;
        }
        _interviews.addAll(newInterviews);
        _page++;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenirken bir hata oluştu: $e')),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _fetchInterviews();
      }
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _fetchInterviews(isRefresh: true);
  }

  Future<void> _showNewInterviewDialog() async {
    // 2. showDialog'un sonucunu await ile bir değişkene (result) atıyoruz
    final result = await showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NewInterviewDialog(repository: repository);
      },
    );

    // 3. Eğer kullanıcı iptal etmediyse ve başarılı bir veri döndüyse (null değilse)
    if (result != null && mounted) {
      try {
        // Gelen tekil veriyi formatlayabilmek için geçici bir listeye koyup
        // mevcut formatlayıcı fonksiyonunuza gönderiyoruz.
        final List<Map<String, dynamic>> formattedList = _formatInterviews([
          result,
        ]);

        if (formattedList.isNotEmpty) {
          final Map<String, dynamic> newInterview = formattedList.first;

          // 4. setState içinde listenin 0. indeksine (en başa) ekliyoruz
          setState(() {
            _interviews.insert(0, newInterview);
          });

          // İsteğe bağlı: Kullanıcıya başarı mesajı gösterebilirsiniz
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Görüşme başarıyla eklendi.')),
          );
        }
      } catch (e) {
        // Herhangi bir formatlama hatasına karşı önlem
        debugPrint("Yeni görüşme listeye eklenirken hata: $e");
      }
    }
  }

  void _showStudentSelectionDialog() {
    final homeProvider = context.read<HomeProvider>();
    // homeProvider.coachStudents listesinin Student modelinden oluştuğunu varsayıyoruz
    final students = homeProvider.coachStudents ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            // Dialog'un ekrandaki maksimum genişlik ve yüksekliğini sınırlıyoruz
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Öğrenci Seçin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                if (students.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Kayıtlı öğrenci bulunamadı.',
                        style: TextStyle(color: AppColors.navUnselected),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];

                        // CRITICAL: "Instance of Student" hatasını çözmek için
                        // Student modelinin içindeki isim alanını (örn: student.name, student.fullName veya student.displayName) buraya yazmalısın.
                        final String studentName = student.name;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryOrange
                                .withOpacity(0.1),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          title: Text(
                            studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.navUnselected,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            // Seçilen student objesiyle yapılacak işlemler (Görüşmeye bağlama vb.)
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Arama Çubuğu ve Ekleme Butonu Alanı
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                // Arama kutusu satırın kalan tüm boşluğunu kaplasın diye Expanded içinde
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Öğrenci ara',
                      hintStyle: const TextStyle(
                        color: AppColors.navUnselected,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primaryOrange,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ), // Arama çubuğu ile buton arasındaki mesafe
                // İstediğin Buton Stili (Arama Çubuğu ile Hizalı)
                SizedBox(
                  width:
                      48, // TextField'ın varsayılan veya padding'li yüksekliğine eşitlemek için
                  height: 48,
                  child: Material(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _showNewInterviewDialog,
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: AppColors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Görüşme Listesi
          Expanded(
            child: _interviews.isEmpty && _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  )
                : _interviews.isEmpty
                ? const Center(
                    child: Text(
                      'Görüşme bulunamadı.',
                      style: TextStyle(color: AppColors.navUnselected),
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primaryOrange,
                    onRefresh: () => _fetchInterviews(isRefresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _interviews.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _interviews.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          );
                        }

                        final interview = _interviews[index];
                        return InterviewCard(
                          interviewData: interview,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InterviewDetailScreen(
                                  interviewData: interview,
                                  repository: repository,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class NewInterviewDialog extends StatefulWidget {
  final CoachRepository repository;
  const NewInterviewDialog({super.key, required this.repository});

  @override
  State<NewInterviewDialog> createState() => _NewInterviewDialogState();
}

class _NewInterviewDialogState extends State<NewInterviewDialog> {
  dynamic _selectedStudent;
  String _interviewType = 'Öğrenci';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Tarih Seçici
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: AppColors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Saat Seçici (AM/PM Kaldırılmış - 24 Saat Formatı Zorunlu)
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: AppColors.white,
              onSurface: Colors.black87,
            ),
          ),
          // AM/PM alanını tamamen kaldırmak için 24 saat modunu zorunlu kılıyoruz
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  // İçeride açılacak korumalı öğrenci listesi pop-up'ı
  void _openStudentPicker(List<dynamic> students) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors
            .white, // İstenmeyen arka plan renk tonlarını engellemek için saf beyaz
        surfaceTintColor: Colors
            .transparent, // Material 3 ile gelen ekstra renk katmanını sıfırlar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Öğrenci Seçiniz',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Divider(height: 20),
              Flexible(
                child: students.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Kayıtlı öğrenci bulunamadı.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: students.length,
                        itemBuilder: (ctx, index) {
                          final student = students[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            title: Text(
                              student.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // İkon yerine Asset Image entegrasyonu
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                24,
                              ), // Yuvarlak görsel için
                              child: Image.asset(
                                'assets/avatars/${student.photo}',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                // Eğer asset bulunamazsa veya yüklenirken hata verirse çalışacak koruma alanı:
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    color: AppColors.primaryOrange.withOpacity(
                                      0.2,
                                    ),
                                    child: Center(
                                      child: Text(
                                        (student.name as String).isNotEmpty
                                            ? student.name!
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.primaryOrange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            onTap: () {
                              setState(() => _selectedStudent = student);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. State sınıfının en üstüne bu değişkeni ekle:
  bool _isLoading = false;

  Future<void> _addInterview() async {
    // Eğer zaten bir istek atılıyorsa, fonksiyonu çalıştırmadan hemen geri dön (Return)
    if (_isLoading) return;

    if (_selectedStudent == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      return;
    }

    // 2. İstek başladığı an yükleniyor durumunu true yap ve UI'ı güncelle
    setState(() {
      _isLoading = true;
    });

    int typeValue = (_interviewType == 'Öğrenci') ? 1 : 2;

    final DateTime combinedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final String formattedIsoDate = combinedDateTime.toIso8601String();

    final Map<String, dynamic> payload = {
      "dataObj": {
        "date": formattedIsoDate,
        "type": typeValue,
        "student": _selectedStudent!.id,
      },
    };

    try {
      final Map<String, dynamic> response = await widget.repository
          .addInterview(payload);

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görüşme başarıyla eklendi! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(response['newInterview']);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold'ın altındaki MediaQuery'den güvenli alanı ve klavye yüksekliğini alıyoruz
    final mediaQuery = MediaQuery.of(context);
    final homeProvider = context.read<HomeProvider>();
    final students = homeProvider.coachStudents ?? [];

    return AnimatedPadding(
      padding:
          mediaQuery.viewInsets +
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Center(
        child: Material(
          color: AppColors.white,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          type: MaterialType.card,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  mediaQuery.size.height *
                  0.85, // Ekranın %85'inden fazlasını kaplamaz, taşmayı önler
              maxWidth:
                  400, // Tablet gibi büyük ekranlarda devasa görünmesini engeller
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve Kapatma Butonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Yeni Görüşme',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1. ÖĞRENCİ SEÇİM ALANI
                    if (_selectedStudent == null) ...[
                      const Text(
                        'Öğrenci',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _openStudentPicker(students),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Görüşme Yapılacak Öğrenciyi Seçin',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: AppColors.primaryOrange,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // Öğrenci seçildikten sonra üst kısımda görünecek Avatar ve İsim
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryOrange.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Korumalı ve Dinamik Asset Fotoğraf Alanı
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                22,
                              ), // Dış çevreyle uyumlu tam yuvarlak hatlar
                              child: Image.asset(
                                'assets/avatars/${_selectedStudent.photo}',
                                width:
                                    44, // Eski radius: 22 değerinin tam çap karşılığı (22 * 2)
                                height: 44,
                                fit: BoxFit.cover,
                                // Eğer seçilen öğrencinin fotoğrafı asset klasöründe yoksa çökmeyi önleyen yedek alan:
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 44,
                                    height: 44,
                                    color: AppColors.primaryOrange,
                                    child: Center(
                                      child: Text(
                                        (_selectedStudent.name as String)
                                                .isNotEmpty
                                            ? _selectedStudent.name
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedStudent.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Seçilen Öğrenci',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.sync_rounded,
                                color: AppColors.primaryOrange,
                              ),
                              onPressed: () => _openStudentPicker(students),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 2. GÖRÜŞME TÜRÜ SEÇİMİ (Kayma ve Taşma Korumalı)
                    const Text(
                      'Görüşme Türü',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Öğrenci Görüşmesi',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            selected: _interviewType == 'Öğrenci',
                            selectedColor: AppColors.primaryOrange.withOpacity(
                              0.2,
                            ),
                            checkmarkColor: AppColors.primaryOrange,
                            showCheckmark:
                                false, // Dar ekranlarda yer kazanmak için checkmark kapatıldı
                            labelStyle: TextStyle(
                              color: _interviewType == 'Öğrenci'
                                  ? AppColors.primaryOrange
                                  : Colors.black87,
                              fontWeight: _interviewType == 'Öğrenci'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (bool selected) {
                              if (selected)
                                setState(() => _interviewType = 'Öğrenci');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Veli Görüşmesi',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            selected: _interviewType == 'Veli',
                            selectedColor: AppColors.primaryOrange.withOpacity(
                              0.2,
                            ),
                            checkmarkColor: AppColors.primaryOrange,
                            showCheckmark:
                                false, // Dar ekranlarda yer kazanmak için checkmark kapatıldı
                            labelStyle: TextStyle(
                              color: _interviewType == 'Veli'
                                  ? AppColors.primaryOrange
                                  : Colors.black87,
                              fontWeight: _interviewType == 'Veli'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (bool selected) {
                              if (selected)
                                setState(() => _interviewType = 'Veli');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 3. TARİH SEÇİMİ
                    const Text(
                      'Tarih',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Tarih Seçiniz'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 4. SAAT SEÇİMİ
                    const Text(
                      'Saat',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _selectTime,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedTime == null
                                  ? 'Saat Seçiniz'
                                  : _selectedTime!.format(context),
                              style: TextStyle(
                                color: _selectedTime == null
                                    ? Colors.grey
                                    : Colors.black87,
                              ),
                            ),
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // KAYDET BUTONU
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        // DÜZELTME: Eğer alanlardan biri boşsa VEYA şu an istek atılıyorsa butonu pasif (null) yap
                        onPressed:
                            _selectedStudent == null ||
                                _selectedDate == null ||
                                _selectedTime == null ||
                                _isLoading
                            ? null
                            : () {
                                _addInterview();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        // DÜZELTME: Yüklenme durumuna göre içerideki widget'ı değiştiriyoruz
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  // Buton pasifken temanın rengine ayak uydurması için progress rengini ayarlıyoruz
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Görüşmeyi Kaydet',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

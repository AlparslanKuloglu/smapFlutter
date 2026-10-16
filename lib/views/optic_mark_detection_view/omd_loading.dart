import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Eklendi
import 'package:studentmap/core/extensions/dartz_extension.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/repository/omd_repository/omd_repository.dart';
import 'package:studentmap/views/optic_mark_detection_view/omd_result_flow_view.dart';

class OmdAnalyzingView extends StatefulWidget {
  final Uint8List imageBytes;
  final OmdRepository repository;

  const OmdAnalyzingView({
    Key? key,
    required this.imageBytes,
    required this.repository,
  }) : super(key: key);

  @override
  State<OmdAnalyzingView> createState() => _OmdAnalyzingViewState();
}

class OmdVerificationView extends StatefulWidget {
  final Map<String, dynamic> responseData;
  final Uint8List originalImage;
  final OmdRepository repository;

  const OmdVerificationView({
    Key? key,
    required this.responseData,
    required this.originalImage,
    required this.repository,
  }) : super(key: key);

  @override
  State<OmdVerificationView> createState() => _OmdVerificationViewState();
}

class ExamNotFoundView extends StatefulWidget {
  final VoidCallback? onBack;
  final OmdRepository repository;
  // Yeni eklediğimiz alanlar:
  final Map<String, dynamic> answerData;

  const ExamNotFoundView({
    super.key,
    this.onBack,
    required this.repository,
    required this.answerData, // Bu satırı ekledik
  });

  @override
  State<ExamNotFoundView> createState() => _ExamNotFoundViewState();
}

class _ExamNotFoundViewState extends State<ExamNotFoundView> {
  // Controller'ları tanımlıyoruz
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _examNameController = TextEditingController();

  @override
  void dispose() {
    // Bellek sızıntısını önlemek için dispose ediyoruz
    _publisherController.dispose();
    _examNameController.dispose();
    super.dispose();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Bilgileri Onayla'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Girdiğin bilgilerle talep oluşturulacak:'),
              const SizedBox(height: 20),
              _infoRow('Yayınevi:', _publisherController.text),
              _infoRow('Deneme:', _examNameController.text),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Düzenle',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162A40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                // 1. Yükleniyor Göstergesi
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                );

                final finalData = {
                  "publisherName": _publisherController.text,
                  "examName": _examNameController.text,
                  "answerData": widget.answerData,
                };

                final prefs = await SharedPreferences.getInstance();
                String? userJson = prefs.getString('user_data');

                // Verinin var olduğundan emin olalım
                if (userJson != null && userJson.isNotEmpty) {
                  final userData =
                      json.decode(userJson) as Map<String, dynamic>;
                  finalData['user'] = userData;
                  // Burada userData'yı güvenle kullanabilirsin
                }
                // 2. API İsteği
                final result = await widget.repository.sendExamDetailToServer(
                  examData: finalData,
                );

                // 3. Yükleniyor'u Kapat
                if (!mounted) return;
                Navigator.pop(context);

                // 4. Başarı Kontrolü
                if (result.isRight()) {
                  Navigator.pop(dialogContext); // Onay kutusunu kapat
                  _showSuccessDialog(); // Başarı kutusunu aç
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bir hata oluştu.')),
                  );
                }
              },
              child: const Text(
                'Onayla ve Gönder',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF162A40),
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Talebin Alındı!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bilgiler sistemimize kaydedildi. Analizin en geç 72 saat içinde hazır olacak.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text(
                    'Ana Sayfaya Dön',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitRequest() {
    // Burada API işlemlerini yapabilirsin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Talebin alındı! 72 saat içinde hazır.')),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value.isEmpty ? '-' : value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneme Bulunamadı'),
        backgroundColor: const Color(0xFF162A40),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 100,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Denemen Henüz Sistemde Mevcut Değil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Üzgünüz, bu deneme henüz sistemimizde tanımlı değil. 72 saat içinde hazırlama sözü veriyoruz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Textfield'lara controller'ları bağladık
            _buildTextField(
              label: 'Yayınevi İsmi',
              hint: 'Örn: Bilgi Sarmal',
              controller: _publisherController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Deneme Adı / Seri',
              hint: 'Örn: TYT 5. Deneme',
              controller: _examNameController,
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _showConfirmDialog, // Pop-up'ı tetikler
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF162A40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Analizimi Hazırlayın',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // Controller ataması kritik
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _OmdVerificationViewState extends State<OmdVerificationView> {
  // Veri yapısı: {"Kolon 1": {"1": "A", "2": "B"}}
  Map<String, Map<String, String>> editedAnswers = {};
  bool _isSending = false; // İşlem durumunu takip etmek için

  String selectedColumn = "Kolon 1"; // Başlangıç seçimi
  final TextEditingController _qNumController = TextEditingController();
  String? _currentOption;
  final List<String> options = ['A', 'B', 'C', 'D', 'E', 'Boş'];
  final List<String> columns = ['Kolon 1', 'Kolon 2', 'Kolon 3', 'Kolon 4'];

  // Tema Renkleri
  final Color primaryColor = const Color(0xFF162A40); // Koyu Lacivert
  final Color accentColor = Colors.orange; // Vurgu (Turuncu)
  final Color successColor = Colors.green; // Onay (Yeşil)

  // Toplam yapılan düzenleme sayısını hesaplar
  int get totalEditCount {
    int count = 0;
    editedAnswers.forEach((key, value) => count += value.length);
    return count;
  }

  // Yeni bir cevabı listeye ekler
  void _addAnswer() {
    if (_qNumController.text.isEmpty || _currentOption == null) return;
    setState(() {
      if (!editedAnswers.containsKey(selectedColumn)) {
        editedAnswers[selectedColumn] = {};
      }
      editedAnswers[selectedColumn]![_qNumController.text] = _currentOption!;
      // Giriş alanlarını temizle
      _qNumController.clear();
      _currentOption = null;
    });
  }

  // Düzenleme Paneli (BottomSheet)
  void _openEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white, // <-- Arka planı tamamen beyaz yapar
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Sadece içeriği kadar yer kaplar
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 133, 140, 148),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Soru Düzenle",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // KOLON SEÇİMİ (Tek Satır, 4 Kolon Yan Yana)
                  SingleChildScrollView(
                    scrollDirection: Axis
                        .horizontal, // Satırı kaydırılabilir yapar (Sığmazsa)
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: columns.map((col) {
                        bool isSel = selectedColumn == col;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(
                              col,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            selected: isSel,
                            selectedColor: accentColor, // Seçiliyken Turuncu
                            backgroundColor: Colors
                                .grey
                                .shade100, // Seçili değilken hafif gri
                            onSelected: (val) {
                              setModalState(() => selectedColumn = col);
                              setState(() => selectedColumn = col);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 30),

                  Row(
                    children: [
                      // Soru Numarası
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: _qNumController,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: "Soru",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Şık Seçimi
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: options.map((opt) {
                            bool isSel = _currentOption == opt;
                            return ChoiceChip(
                              label: Text(
                                opt,
                                style: TextStyle(
                                  color: isSel ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSel,
                              selectedColor:
                                  primaryColor, // Seçiliyken Koyu Lacivert
                              backgroundColor: Colors.grey.shade100,
                              onSelected: (val) {
                                setModalState(() => _currentOption = opt);
                                setState(() => _currentOption = opt);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // Ekle Butonu
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Koyu Lacivert
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _addAnswer();
                      Navigator.pop(context); // Paneli kapat
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "LİSTEYE EKLE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendAnswerArray() async {
    if (_isSending) return; // Zaten gönderiliyorsa fonksiyonu durdur

    //setState(() => _isSending = true); // Yüklemeyi başlat

    try {
      final finalData = {
        "original_data": widget.responseData,
        "edits": editedAnswers,
      };

      final result = await widget.repository.sendAnswerArrayToServer(
        responseData: finalData,
      );

      if (result.isRight()) {
        final successData = result.asRight();
        final responseData = successData.toJson();

        final originalImageFileName =
            widget.responseData['originalImageFileName'];
        final opticImageFileName = widget.responseData['opticImageFileName'];
        final images = {
          "original_image": originalImageFileName,
          "read_image": opticImageFileName,
        };
        responseData['images'] = images;
        // Hatanın çözüldüğü satır: 'as' ile tipini zorunlu kılıyoruz.
        // 1. Veriyi güvenli bir şekilde al (bool gelirse null döner)
        final mexamFound = responseData['mexamFound'] is Map<String, dynamic>
            ? responseData['mexamFound'] as Map<String, dynamic>
            : null;

        // 2. Kontrolü buna göre yap
        if (mexamFound != null) {
          // Sınav bulunduysa OmdResultFlowView'e git
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OmdResultFlowView(data: responseData),
            ),
          );
        } else {
          // Sınav bulunamadıysa (mexamFound false veya null ise) ExamNotFoundView'e git
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamNotFoundView(
                repository: OmdRepository(),
                answerData: responseData,
              ),
            ),
          );
          print("Sınav verisi bulunamadı veya geçersiz.");
        }
      } else {
        setState(() => _isSending = false); // Hata durumunda yüklemeyi bitir
        //_showSnackBar("Sunucu hatası oluştu.");
      }
    } catch (e) {
      setState(() => _isSending = false); // Hata durumunda yüklemeyi bitir
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gönderim hatası 590: $e")));
    }
  }

  // Yapılan Düzenlemeleri Listeleme Pop-up
  void _showEditsSummary() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Yapılan Değişiklikler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: editedAnswers.isEmpty
                    ? const Center(
                        child: Text("Henüz bir değişiklik yapılmadı."),
                      )
                    : ListView(
                        children: editedAnswers.entries.map((col) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  col.key,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              ...col.value.entries.map(
                                (e) => Card(
                                  elevation: 0,
                                  color: Colors.grey.shade50,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  child: ListTile(
                                    title: Text("Soru ${e.key}"),
                                    trailing: Text(
                                      e.value,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: accentColor,
                                      ),
                                    ),
                                    dense: true,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmDialog(BuildContext context) {
    bool _isPopUpLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !_isPopUpLoading,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setPopUpState) {
            return AlertDialog(
              backgroundColor: Colors.white, // Pop-up arka planını beyaz yapar
              surfaceTintColor:
                  Colors.transparent, // Material 3 tint gölgesini sıfırlar
              title: const Text("Onaylıyor musunuz?"),
              content: const Text(
                "Optik formu okutma işlemini onaylıyor musunuz?",
              ),
              actions: [
                if (!_isPopUpLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("İptal"),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 40),
                  ),
                  onPressed: _isPopUpLoading
                      ? null
                      : () async {
                          _sendAnswerArray();
                          setState(() => _isSending = true);
                          Navigator.pop(context);
                        },
                  child: _isPopUpLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Onayla"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF162A40),
      appBar: AppBar(
        title: const Text("Form Kontrol"),
        backgroundColor: const Color(0xFF162A40),
        foregroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0, top: 15.0, bottom: 0.0),
            child: ElevatedButton.icon(
              onPressed: () => _showConfirmDialog(context), // Pop-up'ı açar
              icon: const Icon(Icons.check),
              label: const Text("Onayla"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                side: const BorderSide(color: Colors.orange, width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // RESİM ALANI (TÜM ORTAYI KAPLAR)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                InteractiveViewer(
                  maxScale: 5.0,
                  child: widget.responseData['opticImageFileName'] != null
                      ? Image.network(
                          'https://smaptr.com.tr/uploads/${widget.responseData['opticImageFileName']}',
                          fit: BoxFit.contain, // Resmi sığdırır ama kesmez
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                        )
                      : const Center(child: Text("Resim Yok")),
                ),
                if (_isSending) // Analiz sırasında resmin üstüne binen yükleyici
                  Container(
                    color: Colors.black26, // Arka planı hafif karartır
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                        strokeWidth: 5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ALT ARAÇ ÇUBUĞU (HİÇBİR ŞEY RESMİN ÜSTÜNE BİNMEZ)
          Container(
            // Alt padding değerini artırarak (bottom: 30) butonları yukarı ittik
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 12,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF162A40), // Lacivert arka plan
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // DÜZENLEME YAP BUTONU
                  ElevatedButton.icon(
                    onPressed: _openEditSheet,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Düzenleme Yap"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      foregroundColor: primaryColor,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // SAYAÇ BUTONU
                  ElevatedButton.icon(
                    onPressed: _showEditsSummary,
                    icon: Icon(Icons.list_alt, size: 18, color: primaryColor),
                    label: Text("Düzenlemeler ($totalEditCount)"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade50,
                      foregroundColor: primaryColor,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OmdAnalyzingViewState extends State<OmdAnalyzingView> {
  // Renkler
  final Color kDarkBlue = const Color(0xFF1F2937);
  final Color kOrange = const Color(0xFFFF6F00);

  // Kullanıcı Bilgileri Değişkenleri
  Map<String, dynamic>? userData;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndStartAnalysis();
  }

  // Hem kullanıcıyı yükleyen hem de analizi başlatan ana fonksiyon
  Future<void> _loadUserAndStartAnalysis() async {
    await _getUserData(); // Önce kullanıcıyı çek
    await _startAnalysis(); // Sonra analizi başlat
  }

  // SharedPreferences'dan veriyi çeken fonksiyon
  Future<void> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user_data');

      if (userJson != null) {
        setState(() {
          userData = json.decode(userJson) as Map<String, dynamic>;
          isLoadingUser = false;
        });
      } else {
        setState(() => isLoadingUser = false);
      }
    } catch (e) {
      debugPrint("Kullanıcı verisi yükleme hatası: $e");
      setState(() => isLoadingUser = false);
    }
  }

  Future<void> _startAnalysis() async {
    try {
      final String base64Data = base64Encode(widget.imageBytes);
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user_data');
      final Map<String, dynamic> sendImageData = {"image": base64Data};

      if (userJson != null && userJson.isNotEmpty) {
        // 2. decode işlemini gerçekleştirin
        final userData = json.decode(userJson) as Map<String, dynamic>;

        // 3. Artık burası hata vermeyecek çünkü Map artık 'dynamic' değer kabul ediyor
        sendImageData['user'] = userData;
      }
      // Verinin var olduğundan emin olalım
      if (userJson != null && userJson.isNotEmpty) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        sendImageData['user'] = userData;
        // Burada userData'yı güvenle kullanabilirsin
      } else {
        // Veri yoksa yapılacaklar (örn: giriş sayfasına yönlendir)
        print("Kullanıcı verisi bulunamadı.");
      }
      // UI tarafında kullanım:
      final result = await widget.repository.sendOMImageToServer(
        data: sendImageData,
      );

      if (!mounted) return;

      if (result.isRight()) {
        final successData = result.asRight();
        final responseData = successData.toJson();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OmdVerificationView(
              responseData: responseData, // Sunucudan gelen data
              originalImage: widget.imageBytes, // Öğrencinin gönderdiği resim
              repository: OmdRepository(),
            ),
          ),
        );
      } else {
        final error = result.asLeft();
        _showSnackBar("Hata: $error");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Analiz Hatası: $e");
      if (mounted) {
        _showSnackBar("Bir hata oluştu.");
        Navigator.pop(context);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kDarkBlue,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/smaplogo.png",
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              "SMAP",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage: (userData != null && userData!['photo'] != null)
                  ? AssetImage('assets/avatars/${userData!['photo']}')
                  : const AssetImage('assets/avatars/user.png'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Denemeniz\nAnaliz Ediliyor!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "İşlem birkaç saniye sürebilir.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 36),

              // Görsel Alanı
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: MemoryImage(widget.imageBytes),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Yükleniyor Göstergesi
              SizedBox(
                height: 56,
                width: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(kDarkBlue),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

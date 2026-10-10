import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smapwebflutter/views/main_webview/main_webview.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- GÜNCELLENMİŞ VERİ YAPISI ---
  // 'image' yerine 'images' listesi kullanıyoruz.
  // İlk elemana iki resim yolu ekleyebilirsin.
  final List<Map<String, dynamic>> onboardingData = [
    {
      "images": [
        "assets/ob1.png", // Buraya sol taraftaki mockup gelecek
        "assets/ob2.png" // Buraya sağ taraftaki mockup gelecek
      ],
      "title": "Sana Dair En Detaylı Analiz: Tüm Denemeler! \n Yayınevi farketmeksizin!",
      "desc": "Optik formunu okuttuğunda denemen otomatik saptanır ve 5 saniyede analizin hazırlanır!"
    },
    {
      "images": ["assets/ob5.png"],
      "title": "Smap Neyi Bilmediğini Belirler ve Eksiklerini Gidermeni Sağlar",
      "desc": "Yapay zeka destekli analizlerimizle hangi konuya ne kadar çalışman gerektiğini sana söyleyelim."
    },
    {
      "images": ["assets/ob3.png"], // Diğerleri tek elemanlı liste
      "title": "Denemelerini Okut ve Sana Ait Kümülatif Birikimle İlerlemeni Adım Adım Takip Et!",
      "desc": "Sınav maratonunda kendine hedefler koy ve bu hedeflere ne kadar yaklaştığını anlık olarak izle."
    },
    {
      "images": ["assets/ob4.png"],
      "title": "Güçlü ve Zayıf Yanların: Konularla Karşılaşma Sayıların ve Başarı Yüzdelerin",
      "desc": "Anlamadığın soruların çözümlerine tek tıkla ulaş, eksik konu bırakmadan ilerle."
    },
    {
      "images": ["assets/ob6.png"],
      "title": "YKS'ye Son Teknoloji ile Hazırlan",
      "desc": "Şimdi SMAP dünyasına katıl ve hayalindeki üniversite için en büyük adımı at!"
    },
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      // Navigator.pushReplacement(context, MaterialPageRoute(...)) yerine:
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Sayfa İçeriği
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (int index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  // Veriyi alırken List<String> olarak cast ediyoruz
                  final imagesList = onboardingData[index]["images"] as List<String>;

                  return _buildPageContent(
                    images: imagesList,
                    title: onboardingData[index]["title"] as String,
                    desc: onboardingData[index]["desc"] as String,
                  );
                },
              ),
            ),

            // Sayfa Göstergesi (Indicator)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => _buildIndicator(index),
              ),
            ),

            const SizedBox(height: 40),

            // Butonlar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9ECF2),
                        foregroundColor: const Color(0xFF1A365D),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == onboardingData.length - 1 ? "Hemen Başla" : "Devam Et",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      "Tanıtımı atla",
                      style: TextStyle(
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GÜNCELLENMİŞ WIDGET ---
  Widget _buildPageContent({required List<String> images, required String title, required String desc}) {
    // Görsel alanı içeriğini belirle
    Widget contentWidget;

    if (images.length > 1) {
      // Eğer listede birden fazla resim varsa YAN YANA (Row) koy
      contentWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center, // Ortala
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0), // Araya boşluk
              child: Image.asset(images[0], fit: BoxFit.contain),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0), // Araya boşluk
              child: Image.asset(images[1], fit: BoxFit.contain),
            ),
          ),
        ],
      );
    } else {
      // Tek resim varsa eskisi gibi çalış
      contentWidget = Image.asset(images[0], fit: BoxFit.contain);
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: contentWidget, // Hazırladığımız widget'ı buraya koyuyoruz
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: isActive ? 35 : 20,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1A365D).withOpacity(0.6) : const Color(0xFFE9ECF2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

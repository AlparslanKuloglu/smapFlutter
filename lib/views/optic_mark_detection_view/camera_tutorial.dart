import 'package:flutter/material.dart';

class CameraTutorialOverlay extends StatefulWidget {
  const CameraTutorialOverlay({
    required this.onClose,
    super.key,
    this.showCheckbox = true,
  });

  final void Function(bool dontShowAgain) onClose;
  final bool showCheckbox;

  @override
  State<CameraTutorialOverlay> createState() => _CameraTutorialOverlayState();
}

class _CameraTutorialOverlayState extends State<CameraTutorialOverlay> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Noktaları Köşelere Getirin',
      'desc':
          'Ders isimlerinin yer aldığı yatay dikdörtgeni dahil etmeyin. \n  Beyaz noktaları cevap kutusunun dört köşesiyle eşleştirin. \n Bu, doğru okuma için önemlidir.',
      'image': 'assets/optic4.png',
    },
    // Buraya yeni adımlar ekleyebilirsiniz
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onClose(_dontShowAgain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      // ARKA PLAN: Derin Mavi
      color: const Color(0xFF162A40),
      child: SafeArea(
        child: Column(
          children: [
            // Üstteki Kapat Butonu
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => widget.onClose(_dontShowAgain),
                child: const Text(
                  'Kapat',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // RESİM KUTUSU
                        Container(
                          height: MediaQuery.of(context).size.height * 0.40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              step['image'] as String,
                              fit: BoxFit.fitHeight,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white24,
                                      size: 50,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // BAŞLIK: Parlak Beyaz
                        Text(
                          step['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration
                                .none, // Overlay olduğu için gerekebilir
                          ),
                        ),
                        const SizedBox(height: 15),
                        // AÇIKLAMA: Açık Mavi/Beyaz tonu
                        Text(
                          step['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFE3F2FD),
                            fontSize: 15,
                            height: 1.4,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Alt Kontroller
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Sayfa İndikatörleri (Noktalar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _steps.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "Bir daha gösterme" satırı
                  if (widget.showCheckbox)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _dontShowAgain = !_dontShowAgain),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.white70,
                            ),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _dontShowAgain,
                                activeColor: Colors.white,
                                checkColor: const Color(0xFF0D47A1),
                                side: const BorderSide(color: Colors.white70),
                                onChanged: (val) => setState(
                                  () => _dontShowAgain = val ?? false,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Bir daha gösterme',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ANA BUTON: Beyaz üzerine Lacivert Yazı
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF162A40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _steps.length - 1
                            ? 'ANLADIM'
                            : 'SONRAKİ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

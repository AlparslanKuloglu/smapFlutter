part of '../optic_mark_detection_view.dart';

mixin OMDMixin on State<OpticMarkDetectionView2> {
  late final DocumentScannerController _documentController;
  late final OmdRepository _omdRepository;

  bool _isProcessing = false;

  @override
  void initState() {
    _omdRepository = OmdRepository();
    _documentController = DocumentScannerController();
    super.initState();
  }

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  Future<void> onChangedFrame(Uint8List image) async {
    if (_isProcessing || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      // SharedPreferences beklerken kullanıcı sayfadan çıkmış olabilir
      if (!mounted) return;

      final bool isHidden =
          prefs.getBool('omd_photo_guideline_hidden') ?? false;

      if (!isHidden) {
        final bool? isConfirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const OMDPhotoGuidelineDialog(),
        );

        // Diyalog kapandığında widget hala yerinde mi?
        if (!mounted) return;

        if (isConfirmed == null || isConfirmed == false) {
          setState(() => _isProcessing = false);
          return;
        }
      }

      // Analiz sayfasına gitmeden önce son kontrol
      if (!mounted) return;

      // pushReplacement kullandığın için bu widget kesinlikle dispose edilecek!
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OmdAnalyzingView(imageBytes: image, repository: _omdRepository),
        ),
      );

      // DİKKAT: pushReplacement sonrası bu satıra gelindiğinde
      // bu widget artık ekranda DEĞİLDİR. setState hata verir.
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      debugPrint("OMD Akış Hatası: $e");

      // Hata oluştuğunda widget'ın hala hayatta olup olmadığını kontrol et
      if (!mounted) return;

      _pushMessageToScreen("Bir hata oluştu, lütfen tekrar deneyin.");
      setState(() => _isProcessing = false);
    }
  }

  void _pushMessageToScreen(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _getBack() {
    if (mounted) Navigator.pop(context);
  }
}

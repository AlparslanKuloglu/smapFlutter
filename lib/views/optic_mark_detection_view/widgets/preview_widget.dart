part of '../optic_mark_detection_view.dart';

@immutable
final class OMDPreviewWidget extends StatelessWidget {
  const OMDPreviewWidget({
    required this.onChangedFrame,
    required this.documentScannerController,
    required this.onInfoTap,
    super.key,
  });

  final Future<void> Function(Uint8List imageBytes) onChangedFrame;
  final DocumentScannerController documentScannerController;
  final VoidCallback onInfoTap;

  /// Rehberi/Tutorial'ı açan yardımcı fonksiyon
  Future<void> _showTutorialDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const OMDPhotoGuidelineDialog(),
    );
  }

  /// Kırpma ve Düzenleme ekranlarının sağ üstüne gelecek soru işareti butonu
  Widget _buildHelpButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: MediaQuery.paddingOf(context).top + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: kMinInteractiveDimension,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF162A40), // İstediğin koyu lacivert renk
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          await documentScannerController.changePage(
                            AppPages.takePhoto,
                          );
                        },
                        style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Geri',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/smaplogo.png', // Senin belirttiğin Image ikon
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SMAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.orange.withValues(alpha: .8),
                          ),
                          onPressed: () => _showTutorialDialog(context),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size.square(40),
                            maximumSize: const Size.square(40),
                            fixedSize: const Size.square(40),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () async {
                              // Mevcut sayfanın hangisi olduğunu kontrol ediyoruz
                              // (Not: documentScannerController içinde statusPage yoksa,
                              // bunun yerine bloc üzerinden çekebiliriz veya akışı takip edebiliriz)

                              // En sağlam yöntem: Bloc üzerindeki currentPage değerine bakmak
                              final currentPage = documentScannerController
                                  .bloc
                                  .state
                                  .currentPage;

                              if (currentPage == AppPages.cropPhoto) {
                                // 1. ADIM: Kırpma ekranındaysak (Eski 'TAMAM')
                                // Bu işlem bittiğinde paket otomatik olarak Edit sayfasına geçer.
                                await documentScannerController.cropPhoto();
                              } else if (currentPage == AppPages.editDocument) {
                                // 2. ADIM: Düzenleme ekranındaysak (Eski 'ONAYLA')
                                // Bu işlem senin 'onSave' fonksiyonuna (onChangedFrame) byte'ları gönderir.
                                await documentScannerController
                                    .savePhotoDocument();
                              }
                            },
                            style: TextButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Onayla',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return DocumentScanner(
      controller: documentScannerController,
      generalStyles: const GeneralStyles(hideDefaultDialogs: true),
      onSave: onChangedFrame,
      resolutionCamera: ResolutionPreset.veryHigh,

      // 1. KIRPMA EKRANI
      cropPhotoDocumentStyle: CropPhotoDocumentStyle(
        maskFilter: ImageFilter.blur(),
        textButtonSave: 'TAMAM',
        maskColor: Colors.black38,
        minDistanceDots: kMinInteractiveDimension.toInt(),
        widthBorderArea: 2,
        dotSize: 16,
        hideAppBarDefault: true,
        children: [_buildHelpButton(context)],
      ),

      // 2. DÜZENLEME EKRANI
      editPhotoDocumentStyle: EditPhotoDocumentStyle(
        hideBottomBarDefault: true,
        textButtonSave: 'ONAYLA',
        children: [_buildHelpButton(context)],
      ),

      // 3. İLK FOTOĞRAF ÇEKME EKRANI
      takePhotoDocumentStyle: TakePhotoDocumentStyle(
        hideDefaultButtonTakePicture: true,
        children: [
          // ÜST BAR: Kapat (Turuncu) - Logo - Bilgi (Turuncu)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 12,
            right: 12,
            child: Container(
              height: kMinInteractiveDimension,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF162A40), // İstediğin koyu lacivert renk
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.orange,
                    ), // Turuncu yapıldı
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/smaplogo.png', // Senin belirttiğin Image ikon
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SMAP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.help_outline, // Soru işareti ikonuyla değiştirildi
                      color: Colors.orange,
                      size: 28.0, // Boyutu buradan ayarlayabilirsin
                    ),
                    onPressed: onInfoTap,
                  ),
                ],
              ),
            ),
          ),

          // ALT KISIM: Flaş ve Çekim Butonu
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: documentScannerController.takePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

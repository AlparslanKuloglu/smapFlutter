import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ekle
import 'package:smap/repository/omd_repository/omd_repository.dart';
import 'package:smap/views/optic_mark_detection_view/omd_loading.dart';
import 'package:smap/views/optic_mark_detection_view/omd_warp_tutorial.dart';


import 'camera_tutorial.dart'; // Eğer ayrı dosyadaysa import et

part 'mixins/omd_mixin.dart';
part 'widgets/preview_top_info_widget.dart';
part 'widgets/preview_widget.dart';

@immutable
final class OpticMarkDetectionView2 extends StatefulWidget {
  const OpticMarkDetectionView2({super.key});

  @override
  State<OpticMarkDetectionView2> createState() => _OpticMarkDetectionView2State();
}

class _OpticMarkDetectionView2State extends State<OpticMarkDetectionView2> with OMDMixin {
  bool _showTutorial = false;
  bool _isManualOpen = false; // Bilgi butonuyla mı açıldı kontrolü
  static const String _storageKey = 'omd_tutorial_hidden';

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus(); // Ekran açılırken kontrol et
  }

  // Hafızadaki durumu kontrol eder
  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isHidden = prefs.getBool(_storageKey) ?? false;

    if (!isHidden) {
      setState(() => _showTutorial = true);
    }
  }

  // "Bir daha gösterme" butonu veya tutorial kapatıldığında hafızaya yazar
  Future<void> _setTutorialHidden() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, true);
    setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          OMDPreviewWidget(
            onChangedFrame: onChangedFrame,
            documentScannerController: _documentController,
            onInfoTap: () {
              setState(() {
                _isManualOpen = true; // El ile açıldı
                _showTutorial = true;
              });
            },
          ),
          if (_showTutorial)
            CameraTutorialOverlay(
              // EĞER manuel açıldıysa checkbox'ı GİZLE (false gönder)
              showCheckbox: !_isManualOpen,
              onClose: (bool dontShowAgain) async {
                if (dontShowAgain) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('omd_tutorial_hidden', true);
                }
                setState(() {
                  _showTutorial = false;
                  _isManualOpen = false; // Kapatınca durumu sıfırla ki bir sonraki otomatik açılışı bozmasın
                });
              },
            ),
        ],
      ),
    );
  }
}

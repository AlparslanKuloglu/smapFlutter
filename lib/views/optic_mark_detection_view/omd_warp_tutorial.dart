import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OMDPhotoGuidelineDialog extends StatefulWidget {
  const OMDPhotoGuidelineDialog({super.key});

  @override
  State<OMDPhotoGuidelineDialog> createState() =>
      _OMDPhotoGuidelineDialogState();
}

class _OMDPhotoGuidelineDialogState extends State<OMDPhotoGuidelineDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Arka plan rengi isteğine göre güncellendi
      backgroundColor: const Color(0xFF162A40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Hatırlatma',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Görselinizin buna benzer göründüğünden, ders kutularının yer almadığından emin olun.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // ÖRNEK GÖRSEL ALANI
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/org1.jpg',
                // Görseli kutuya tam sığdırır
                fit: BoxFit.fill,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // BİR DAHA GÖSTERME SEÇENEĞİ
          InkWell(
            onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _dontShowAgain,
                    activeColor: Colors.orange,
                    side: const BorderSide(color: Colors.white54),
                    onChanged: (val) => setState(() => _dontShowAgain = val!),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bir daha gösterme',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'GERİ',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            if (_dontShowAgain) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('omd_photo_guideline_hidden', true);
            }
            Navigator.pop(context, true);
          },
          child: const Text(
            'GÖNDER',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

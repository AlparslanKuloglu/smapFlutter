import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/analytics/presentation/screens/my_test_result_detail_screen.dart';

class MyTestResultsCard extends StatefulWidget {
  final dynamic data;
  const MyTestResultsCard({super.key, this.data});

  @override
  State<MyTestResultsCard> createState() => _MyTestResultsCardState();
}

class _MyTestResultsCardState extends State<MyTestResultsCard> {
  bool _isStarred = false;

  @override
  void initState() {
    super.initState();
    // Backend'den isStarred geliyorsa başlat, gelmiyorsa false
    _isStarred = widget.data['isStarred'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // Backend'deki anahtar isimlerine göre buraları teyit et
    final String netText = "${widget.data['net'] ?? '0'} net";
    final String examNo = "Deneme: ${widget.data['mexam']['order'] ?? ''}";
    final String title = widget.data['itemName'] ?? "Deneme Sınavı";
    final String? image = widget.data['mexam']?['image'];
    final String fullUrl = 'https://smaptr.com.tr/uploads/$image';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.menuCardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                netText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(examNo, style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.grey.shade100,
                    child: (image != null && image.isNotEmpty)
                        ? Image.network(
                            fullUrl,
                            fit: BoxFit.contain,
                            // Resim yüklenirken çıkacak yapı
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            // HATA ALIRSA MEVCUT YAPI (ICON) GÖZÜKSÜN
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _isStarred = !_isStarred),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        _isStarred
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.white, thickness: 1.5),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(color: AppColors.white, thickness: 2),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 28,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          MyTestResultDetailScreen(data: widget.data),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appBarBackground,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Detay",
                  style: TextStyle(color: AppColors.white, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

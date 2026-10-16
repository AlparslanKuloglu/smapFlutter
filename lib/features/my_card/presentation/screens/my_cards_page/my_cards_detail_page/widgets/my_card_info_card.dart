import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/repository/cards_repository.dart';

class MyCardInfoCard extends StatefulWidget {
  const MyCardInfoCard({
    super.key,
    required this.data,
    required this.isFavorite,
    required this.onDetailTap,
    required this.repository,
    required this.tabName,
    this.onRemove, // Öğrendim başarılı olunca tetiklenir
    this.onFavoriteStatusChanged, // Favori durumu değişince üst sayfayı haberdar etmek için (isteğe bağlı)
  });

  final Map<String, dynamic> data;
  final bool isFavorite;
  final VoidCallback onDetailTap;
  final CardsRepository repository;
  final String tabName;
  final VoidCallback? onRemove;
  final ValueChanged<bool>? onFavoriteStatusChanged;
  @override
  State<MyCardInfoCard> createState() => _MyCardInfoCardState();
}

class _MyCardInfoCardState extends State<MyCardInfoCard> {
  final cardScrollController = ScrollController();
  bool _isLoading = false; // Öğrendim butonu için loading
  bool _isFavoriteLoading = false; // Yıldız butonu için YENİ loading
  late bool _localIsFavorite; // Kartın kendi içindeki favori durumu

  @override
  void initState() {
    super.initState(); // Doğru kullanım budur
    // Dışarıdan gelen ilk favori değerini lokal değişkene eşitleyelim
    _localIsFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(covariant MyCardInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Eğer üst widget'tan gelen veri değişirse lokali de güncelle
    if (oldWidget.isFavorite != widget.isFavorite) {
      _localIsFavorite = widget.isFavorite;
    }
  }

  // --- FAVORİ İŞLEMLERİ ---
  Future<void> _handleFavoriteTap() async {
    if (_isFavoriteLoading) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      final itemId = widget.data['itemId'];
      final response = await widget.repository.addFavoriteMobil(itemId);
      if (response['success'] == true) {
        setState(() {
          _localIsFavorite =
              !_localIsFavorite; // Durumu tersine çevir (0 -> 1 veya true -> false)
        });
        // Üst sayfaya durumun değiştiğini haber ver (örneğin favoriler sayfasındaysa listeden düşmesi için)
        if (widget.onFavoriteStatusChanged != null) {
          widget.onFavoriteStatusChanged!(_localIsFavorite);
        }
      }
    } catch (e) {
      // Hata yönetimi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Favori işlemi gerçekleştirilemedi.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFavoriteLoading = false;
        });
      }
    }
  }

  // --- ÖĞRENDİM İŞLEMLERİ ---
  Future<void> _handleLearnedTap() async {
    final prefs = await SharedPreferences.getInstance();
    bool skipDialog = prefs.getBool('skip_learned_dialog') ?? false;

    if (skipDialog) {
      _sendLearnedRequest();
    } else {
      _showLearnedConfirmationDialog(prefs);
    }
  }

  void _showLearnedConfirmationDialog(SharedPreferences prefs) {
    bool dontShowAgain = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF0F294A)),
                  SizedBox(width: 8),
                  Text(
                    'Öğrendim',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Bu kart 'Bildiklerim' kısmına kaydedilecektir ve eksiklerinizden kaldırılacaktır.",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setDialogState(() {
                        dontShowAgain = !dontShowAgain;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Checkbox(
                          value: dontShowAgain,
                          activeColor: const Color(0xFF0F294A),
                          onChanged: (val) {
                            setDialogState(() {
                              dontShowAgain = val ?? false;
                            });
                          },
                        ),
                        const Text(
                          'Bir daha gösterme',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Vazgeç',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F294A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (dontShowAgain) {
                      await prefs.setBool('skip_learned_dialog', true);
                    }
                    if (mounted) Navigator.of(context).pop();
                    _sendLearnedRequest();
                  },
                  child: const Text(
                    'Tamam',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _sendLearnedRequest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final itemId = widget.data['itemId'];
      final response = await widget.repository.learnedCard(itemId);

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.appBarBlueGrey,
              content: Text("Kart, bildiklerin kısmına aktarıldı."),
            ),
          );
        }

        if (widget.onRemove != null) {
          widget.onRemove!();
        }
      }
    } catch (e) {
      // Hata yönetimi
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/icons/historybook2.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.book,
                      size: 22,
                      color: Color(0xFF0F294A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.data['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Color.fromARGB(255, 234, 235, 238),
            indent: 16,
            endIndent: 16,
          ),
          Expanded(
            child: Scrollbar(
              controller: cardScrollController,
              thumbVisibility: true,
              thickness: 3,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                controller: cardScrollController,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                  left: 20,
                  right: 26,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.data['subtitle'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        // YENİLENEN YILDIZ / SARI LOADING ALANI
                        _isFavoriteLoading
                            ? const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.amber, // Sarı renk loading
                                  ),
                                ),
                              )
                            : IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  _localIsFavorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 26,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : _handleFavoriteTap,
                              ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.data['content'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            height: 0,
            color: Color.fromARGB(255, 234, 235, 238),
            indent: 16,
            endIndent: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.tabName == "failedCards")
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleLearnedTap,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color(0xFFE5E5E5),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF6600),
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Color(0xFFFF6600),
                          ),
                    label: const Text(
                      'Öğrendim',
                      style: TextStyle(
                        color: Color(0xFFFF6600),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                TextButton(
                  onPressed: widget.onDetailTap,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0F294A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Detay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6600).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

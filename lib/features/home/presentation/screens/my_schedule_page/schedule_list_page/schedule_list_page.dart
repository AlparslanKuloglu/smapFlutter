import 'package:flutter/material.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_add_button.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_card.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_filter_button.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_filter_panel.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_search_field.dart';
import 'package:studentmap/features/home/presentation/screens/my_schedule_page/schedule_list_page/widgets/schedule_list_toolbar_row.dart';

import 'package:studentmap/features/home/presentation/screens/my_schedule_page/day_selection_page/day_selection_page.dart';
import 'package:studentmap/repository/weekly_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({
    super.key,
    required this.onAddPressed,
    required this.repository,
    required this.allLessons,
  });

  final VoidCallback onAddPressed;
  final WeeklyRepository repository; // <-- Değişkeni tanımladık
  final dynamic allLessons;

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _filterOpen = false;

  // --- LOKAL STATE VE REPOSITORY YÖNETİMİ ---
  bool _isLoading = true;
  List<dynamic> _schedules = [];
  @override
  void initState() {
    super.initState();
    _fetchSchedulesFromRepository(); // Sayfa açılır açılmaz isteği başlat
  }

  // Sayfa içinde taklit (mock) repository fonksiyonu
  Future<void> _fetchSchedulesFromRepository() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Veriyi repository'den çekiyoruz
      final result = await widget.repository.getMyWeeklies();

      // Sayfa hala açık mı kontrolü (İlk asenkron işlem sonrası)
      if (!mounted) return;

      setState(() {
        _schedules = result['weeklies'] ?? [];
      });

      // 2. bagItems verisini alıyoruz
      final bagItems = result['bagItems'] ?? [];
      // SharedPreferences için veriyi güvenli bir şekilde JSON String'e çeviriyoruz
      final String bagItemsJsonString = jsonEncode(bagItems);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bagItemsStr', bagItemsJsonString);
    } catch (e) {
      // Hata durumunda loglama veya kullanıcıya bildirme yapabilirsin
      debugPrint("Schedule yüklenirken hata oluştu: $e");
    } finally {
      // 3. Sayfa hala ekrandaysa yükleniyor durumunu kapatıyoruz
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // ------------------------------------------

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduleListToolbarRow(
          leading: ScheduleListFilterButton(
            onPressed: () {
              // Sayfa yüklenirken filtrenin açılmasını engelliyoruz
              if (_isLoading) return;
              setState(() => _filterOpen = !_filterOpen);
            },
          ),
          center: ScheduleListSearchField(
            controller: _searchController,
            filterActive: _filterOpen,
          ),
          trailing: ScheduleListAddButton(
            onPressed: () async {
              // Yeni program eklendiği için initialSchedule parametresine null geçiyoruz
              final newWeekly = await DaySelectionPage.open(
                context,
                repository: widget.repository,
                allLessons: widget.allLessons,
                initialSchedule: null,
              );

              // Sayfa kapandığında elimize bir veri ulaştıysa local listemizin EN BAŞINA ekliyoruz
              if (newWeekly != null &&
                  newWeekly is Map<String, dynamic> &&
                  mounted) {
                setState(() {
                  _schedules.insert(0, newWeekly);
                });
              }
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              : Stack(
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      // Lokal listemizin uzunluğuna göre kart basıyoruz
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];

                        return ScheduleListCard(
                          schedule: schedule,
                          onPressed: () async {
                            // 🚀 1. Burayı async yaptık

                            // 🚀 2. Kart tıklandığında sayfanın açılmasını ve kapanırken getireceği veriyi bekliyoruz
                            final updatedWeekly = await DaySelectionPage.open(
                              context,
                              repository: widget.repository,
                              allLessons: widget.allLessons,
                              initialSchedule:
                                  schedule, // Düzenleme modu olduğu için mevcut kartı yolladık
                            );

                            // 🚀 3. Eğer kullanıcı düzenleyip kaydettiyse listeyi güncelliyoruz
                            if (updatedWeekly != null &&
                                updatedWeekly is Map<String, dynamic> &&
                                mounted) {
                              setState(() {
                                // Listenin içinden o an düzenlediğimiz kartın index'ini ID'sinden buluyoruz
                                final existingIndex = _schedules.indexWhere(
                                  (item) => item['_id'] == updatedWeekly['_id'],
                                );

                                if (existingIndex != -1) {
                                  // Kart listede zaten varsa, eski halini API'den gelen taze haliyle değiştiriyoruz
                                  _schedules[existingIndex] = updatedWeekly;
                                }
                              });
                            }
                          },
                        );
                      },
                    ),
                    if (_filterOpen) ...[
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => setState(() => _filterOpen = false),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {},
                          child: ScheduleListFilterPanel(
                            onApply: () => setState(() => _filterOpen = false),
                            onClear: () {},
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

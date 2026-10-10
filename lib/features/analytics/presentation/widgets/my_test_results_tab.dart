import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smap/features/analytics/presentation/provider/analytics_view_provider.dart';
import 'my_test_results_card.dart';

class MyTestResultsTab extends StatefulWidget {
  const MyTestResultsTab({super.key});

  @override
  State<MyTestResultsTab> createState() => _MyTestResultsTabState();
}

class _MyTestResultsTabState extends State<MyTestResultsTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  // Tab değiştirildiğinde durumun ve fotoğrafların hafızada korunmasını sağlar
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<AnalyticsViewNotifier>();
      // SADECE daha önce veri çekilmediyse ilk yüklemeyi yap
      // Böylece menüden her gelindiğinde fotoğraflar/veriler sıfırlanıp tekrar istenmez
      if (notifier.state.myMockExams.isEmpty) {
        notifier.getMyMockExams();
      }
    });
  }

  void _onScroll() {
    // Listenin sonuna yaklaşıldığında (200 piksel kala)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AnalyticsViewNotifier>().getMyMockExams();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için zorunludur!

    final notifier = context.watch<AnalyticsViewNotifier>();
    final state = notifier.state;
    final exams = state.myMockExams;

    // 1. Durum: İlk yükleme (Hiç veri yok ve yükleniyor)
    if (exams.isEmpty && state.isLoadingMore && state.page == 1) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Durum: Boş liste sonucu
    if (exams.isEmpty && !state.isLoadingMore) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Henüz bir deneme sonucu bulunamadı."),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => notifier.getMyMockExams(isRefresh: true),
              child: const Text("Yeniden Dene"),
            ),
          ],
        ),
      );
    }

    // 3. Durum: Veri var - Profesyonel Scroll Yapısı
    return RefreshIndicator(
      onRefresh: () => notifier.getMyMockExams(isRefresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        physics:
            const AlwaysScrollableScrollPhysics(), // Liste boş olsa bile aşağı çekmeyi sağlar
        slivers: [
          // Grid Kısmı
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return MyTestResultsCard(data: exams[index]);
              }, childCount: exams.length),
            ),
          ),

          // Alt taraftaki Loading İkonu - Tam Ortalanmış
          if (state.hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),

          // Eğer veri bittiyse en alta küçük bir boşluk bırakmak şıktır
          if (!state.hasMore && exams.isNotEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

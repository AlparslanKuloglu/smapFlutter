import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/cards/application/card_deck_loader.dart';
import 'package:smap/features/cards/application/deck_card.dart';
import 'package:smap/features/cards/application/deck_group.dart';
import 'package:smap/features/cards/application/deck_lessons.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/cards/presentation/deck/card_deck_state.dart';
import 'package:smap/features/cards/presentation/deck/card_deck_viewmodel.dart';
import 'package:smap/features/cards/presentation/deck/sheets/deck_prompts.dart';
import 'package:smap/features/cards/presentation/widgets/card_deck.dart';
import 'package:smap/features/cards/presentation/widgets/info_card_face.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/gen/assets.gen.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/indicators/app_linear_progress.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';

part 'widgets/card_deck_cards.dart';
part 'widgets/card_deck_header.dart';
part 'widgets/card_deck_states.dart';

/// Kart Destesi (pano 8.1 "Kart Destesi · 4 Kare", 8.2 koyu; flow 13.9 "Bilgi
/// Kartları"; spec §4.G; route `/lessons/deck?lessonId=&examId=&group=`).
///
/// One lesson's info cards as a deck: Back, the title "Tarih Kartları", the
/// segment Eksiklerim / Bildiklerim / Favorilerim with its counters ("23 kart",
/// "kart yok"), the session progress "12/23" and the cards, with "Detay" and
/// "Öğrendim" under them. A swipe only goes on to the next card; "Öğrendim"
/// (only on a missing card, only by the button) moves the card to Bildiklerim
/// after a one-time confirmation, and the toast "Kart Bildiklerim'e taşındı."
/// takes it back for 6 s. When every missing card is learned the empty state
/// "Bu derste eksik kartın kalmadı." offers "Bildiklerime Geç". The bottom bar
/// stays (Derslerim is the tab).
///
/// [lessonId] is the backend (exam) lesson of the deck (`LessonIds.forTrack`);
/// [examId] opens the cards an exam earned ("Deneme Kartları"; narrowed to
/// [lessonId] when both are given); [group] (`eksik`, `bildik`, `favori`)
/// picks the group the deck opens on, Eksiklerim without it.
@RoutePage()
class CardDeckView extends StackedView<CardDeckViewModel> {
  const CardDeckView({
    @QueryParam('lessonId') this.lessonId,
    @QueryParam('examId') this.examId,
    @QueryParam('group') this.group,
    super.key,
  });

  final String? lessonId;
  final String? examId;
  final String? group;

  @override
  bool get reactive => false;

  @override
  CardDeckViewModel viewModelBuilder(BuildContext context) => CardDeckViewModel(
    lessonId: lessonId,
    examId: examId,
    group: DeckGroup.parse(group),
    loader: CardDeckLoader(
      cards: locator<CardRepository>(),
      exams: locator<ExamRepository>(),
    ),
    cards: locator<CardRepository>(),
    preferences: locator<DevicePreferences>(),
    toast: locator<ToastService>(),
    prompts: SheetCardDeckPrompts(l10n: AppLocalizations.of(context)),
  );

  @override
  void onViewModelReady(CardDeckViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    CardDeckViewModel viewModel,
    Widget? child,
  ) => const _DeckPage();
}

/// The page: the bar, the title, the segment, the progress and the deck area,
/// in one `CustomScrollView`; the bottom bar stays under it.
class _DeckPage extends StatelessWidget {
  const _DeckPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          const _DeckBar(),
          const _DeckTitle(),
          const _DeckSegments(),
          const _DeckProgress(),
          const _DeckStage(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppBottomBar.heightOf(context) + AppSpacing.s16,
            ),
          ),
        ],
      ),
    );
  }
}

/// The title: "Tarih Kartları" for a lesson, "Deneme Kartları" for an exam,
/// "Bilgi Kartları" for a lesson outside the catalog.
String _deckTitle(AppLocalizations l10n, DeckHeaderData data) {
  if (data.isExam) return l10n.cardDeck_titleExam;
  final lesson = data.lessonName;
  return lesson == null
      ? l10n.cardDeck_titleFallback
      : l10n.cardDeck_title(lesson);
}

/// An empty sliver: a section that is not showing.
const Widget _noSliver = SliverToBoxAdapter(child: SizedBox.shrink());

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/coach_code_text.dart';
import 'package:smap/features/account/presentation/account/sheets/coach_code_viewmodel.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/presentation/widgets/code_card_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The coach's code sheet, opened by the "Koçluk kodun" row of Hesap (pano
/// 14.11 kare 2 to 6; dark: pano 14.12 kare 4; T12.25): the title "Koçluk
/// kodun" with "Kapat", and under it the [CodeCardSheetBody] (C35 `CodeCard`
/// sheet hâli): the code centered in `metricMd`, "Öğrencin bu kodu Hesap ›
/// Koçluk'a girince sana bağlanır; denemelerini, analizlerini ve programını
/// görürsün.", "Bağlantıyı öğrencin istediği an kaldırabilir. Öğrenci hesabını
/// sen açmak istersen: Öğrencilerim › +." and the equal outlined "Kopyala" and
/// "Paylaş".
///
/// Kare 3: "Kopyala" toasts "Kod kopyalandı." above the buttons and the sheet
/// stays open. Kare 4: the code is a skeleton and the buttons are off (15 s
/// at most). Kare 5: the error "Kodun yüklenemedi." with "Tekrar Dene" sits in
/// the card. Kare 6: the code is read from the device, "Kod cihazında saklı;
/// çevrimdışında da kopyalayıp paylaşabilirsin." shows and the offline strip
/// stays above the sheet. The code reads letter by letter ("Koçluk kodun M O Z
/// K tire 4 8 2 1").
class CoachCodeSheet extends StatelessWidget {
  const CoachCodeSheet({super.key});

  /// Opens the sheet on the root navigator; completes when it is closed. The
  /// offline strip shows above it while the device has no connection.
  static Future<void> show({BuildContext? context}) => AppSheet.show<void>(
    context: context,
    online: locator<ConnectivityService>().online,
    builder: (_) => const CoachCodeSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ViewModelBuilder<CoachCodeViewModel>.reactive(
      viewModelBuilder: () => CoachCodeViewModel(
        currentUser: locator<CurrentUserService>(),
        actions: CoachCodeActions.system(toast: locator<ToastService>()),
        online: locator<ConnectivityService>().online,
      ),
      onViewModelReady: (viewModel) => unawaited(viewModel.init()),
      builder: (context, viewModel, _) {
        final code = viewModel.code;
        final dash = l10n.account_codeSheetDash;
        return AppSheetFrame(
          title: l10n.account_coachCodeTitle,
          bodyPadding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s12,
            AppSpacing.s24,
            0,
          ),
          body: CodeCardSheetBody(
            phase: switch (viewModel.state) {
              SectionState.loading => CodeCardPhase.loading,
              SectionState.ready => CodeCardPhase.ready,
              _ => CodeCardPhase.error,
            },
            code: code,
            spokenCode: code == null
                ? null
                : l10n.account_codeSheetCodeA11y(
                    CoachCodeText.spoken(code, dash: dash),
                  ),
            paragraphs: [
              l10n.account_codeSheetBody1,
              l10n.account_codeSheetBody2,
            ],
            note: viewModel.showStoredNote
                ? l10n.account_codeSheetOfflineNote
                : null,
            errorTitle: l10n.account_codeSheetErrorTitle,
            errorMessage: l10n.account_codeSheetErrorMessage,
            onRetry: () => unawaited(viewModel.retry()),
            loadingLabel: l10n.account_codeSheetLoading,
            onCopy: () => unawaited(viewModel.copy()),
            onShare: (origin) =>
                unawaited(viewModel.share(l10n, origin: origin)),
          ),
        );
      },
    );
  }
}

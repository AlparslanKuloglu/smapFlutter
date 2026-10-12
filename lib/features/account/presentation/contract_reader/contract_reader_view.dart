import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/account/application/legal_entries.dart';
import 'package:smap/features/account/data/dtos/legal_document_dto.dart';
import 'package:smap/features/account/presentation/account_texts.dart';
import 'package:smap/features/account/presentation/contract_reader/contract_reader_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/features/account/presentation/account_bar_clearance.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';

part 'widgets/contract_reader_text.dart';

/// The reading screen of one legal text (pano 9.7 kare 2; spec §4.H 9.7;
/// flow 13.10; route `/account/agreements/read`).
///
/// A detail bar with Back and the text's name already small in it ("başlık
/// bara inmiş"), the version under it ("Sürüm 1.2.0"; the design's date is
/// not sent by the server) and the text: the server's HTML in the app's own
/// type (16/26 body, 17/24 · 700 headings), not a web view.
@RoutePage()
class ContractReaderView extends StackedView<ContractReaderViewModel> {
  const ContractReaderView({required this.document, super.key});

  /// The legal text to read.
  final LegalDocumentDto document;

  @override
  bool get reactive => false;

  @override
  ContractReaderViewModel viewModelBuilder(BuildContext context) =>
      ContractReaderViewModel(
        entry: LegalEntry(
          document: document,
          kind: LegalKind.of(document.name),
        ),
      );

  @override
  Widget builder(
    BuildContext context,
    ContractReaderViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context);
    final entry = viewModel.entry;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          AppDetailBar(
            title: legalEntryTitle(l10n, entry),
            compactAlways: true,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.s8,
              AppSpacing.gutter,
              accountBarClearance(context) + AppSpacing.s16,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                if (legalEntryVersion(l10n, entry) case final version?)
                  _ReaderVersion(version: version),
                if (viewModel.hasText)
                  _ReaderText(html: viewModel.html)
                else
                  const _ReaderEmpty(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

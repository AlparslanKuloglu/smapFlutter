import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/legal_entries.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/account_texts.dart';
import 'package:smap/features/account/presentation/contracts/contracts_viewmodel.dart';
import 'package:smap/features/account/presentation/stack_account_navigator.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';

part 'widgets/contracts_list.dart';
part 'widgets/contracts_states.dart';

/// Sözleşmeler (pano 9.7 kare 1; spec §4.H 9.7; flow 13.10; route
/// `/account/agreements`).
///
/// The detail bar and the large title "Sözleşmeler", then one card of rows
/// (file icon, the text's name, "Sürüm 1.2.0", an arrow) with the note "Kayıt
/// olurken bu sürümleri onayladın…" under it. A row opens the reading screen.
/// The texts load from the server: a skeleton of three rows while they come,
/// the error state with "Tekrar Dene" after 15 s or a failure, an empty state
/// when the server sends none.
@RoutePage()
class ContractsView extends StackedView<ContractsViewModel> {
  const ContractsView({super.key});

  @override
  bool get reactive => false;

  @override
  ContractsViewModel viewModelBuilder(BuildContext context) =>
      ContractsViewModel(
        accounts: locator<AccountRepository>(),
        navigator: StackAccountNavigator(context.router),
      );

  @override
  void onViewModelReady(ContractsViewModel viewModel) =>
      unawaited(viewModel.init());

  @override
  Widget builder(
    BuildContext context,
    ContractsViewModel viewModel,
    Widget? child,
  ) => const _ContractsPage();
}

/// The page: the bar, the title and the list in one `CustomScrollView`.
class _ContractsPage extends StatelessWidget {
  const _ContractsPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          AppDetailBar(title: l10n.account_contractsTitle),
          LargeTitleSliver(title: l10n.account_contractsTitle),
          const _ContractsBody(),
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

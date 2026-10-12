import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/account/application/avatar_catalog.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Avatarını seç" (pano 9.2 kare 3; C57 sheet form, board 1.17): the seven
/// avatars at once in a grid of four 72 pt columns, "7 avatar" under the
/// title and one primary "Bu Avatarı Kullan".
///
/// The chosen avatar has a 3 pt gap in the sheet's color and a 2 pt ring in
/// `primary` around it. Choosing only marks it; the sheet closes with the
/// index on "Bu Avatarı Kullan" and the choice becomes permanent with the
/// profile's "Kaydet". Dismissing the sheet returns `null`. Each avatar is
/// read "Avatar 3, seçili".
class AvatarSheet extends StatefulWidget {
  const AvatarSheet({this.selectedIndex, super.key});

  /// The avatar in use; `null` when it is not one of the seven (nothing is
  /// marked and the button waits for a choice).
  final int? selectedIndex;

  /// Four avatars to a row, 20 between the rows (pano 9.2 kare 3).
  static const int columns = 4;
  static const double _rowGap = 20;

  /// Space above the grid (pano 9.2 kare 3: padding 20 24 0).
  static const double _gridTop = 20;

  /// Opens the sheet on the root navigator; completes with the chosen index
  /// or `null`.
  static Future<int?> show({int? selectedIndex}) => AppSheet.show<int>(
    size: AppSheetSize.medium,
    builder: (_) => AvatarSheet(selectedIndex: selectedIndex),
  );

  @override
  State<AvatarSheet> createState() => _AvatarSheetState();
}

class _AvatarSheetState extends State<AvatarSheet> {
  late int? _selected = widget.selectedIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected;
    final rows = <List<int>>[
      for (var i = 0; i < AvatarCatalog.count; i += AvatarSheet.columns)
        [
          for (var j = i; j < i + AvatarSheet.columns; j++)
            if (j < AvatarCatalog.count) j,
        ],
    ];
    return AppSheetFrame(
      title: l10n.account_avatarTitle,
      subtitle: l10n.kit_avatarCount(AvatarCatalog.count),
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AvatarSheet._gridTop,
        AppSpacing.s24,
        0,
      ),
      body: Column(
        children: [
          for (final (r, row) in rows.indexed) ...[
            if (r > 0) const SizedBox(height: AvatarSheet._rowGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var c = 0; c < AvatarSheet.columns; c++)
                  if (c < row.length)
                    _AvatarCell(
                      index: row[c],
                      selected: row[c] == selected,
                      onTap: () => setState(() => _selected = row[c]),
                    )
                  else
                    const SizedBox.square(dimension: AppAvatarSize.sheet),
              ],
            ),
          ],
        ],
      ),
      primary: AppSheetAction(
        label: l10n.account_avatarUse,
        onPressed: selected == null
            ? null
            : () => Navigator.of(context).pop(selected),
      ),
    );
  }
}

/// One avatar of the grid: 72 pt, with the selection ring outside it.
class _AvatarCell extends StatelessWidget {
  const _AvatarCell({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  /// The gap and the ring around the chosen avatar (pano 9.2 kare 3, 1.17).
  static const double _gap = 3;
  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    const out = _gap + _ring;
    final label = l10n.kit_a11yAvatarOption(index + 1);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, ${l10n.account_avatarSelected}' : label,
      excludeSemantics: true,
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        haptic: !selected,
        scale: 1,
        builder: (context, states) {
          final ring = selected || states.contains(WidgetState.focused);
          return SizedBox.square(
            dimension: AppAvatarSize.sheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: AppAvatar(
                    name: '',
                    image: AssetImage(AvatarCatalog.assetAt(index)),
                    size: AppAvatarSize.sheet,
                    decorative: true,
                  ),
                ),
                Positioned(
                  left: -out,
                  top: -out,
                  right: -out,
                  bottom: -out,
                  child: IgnorePointer(
                    // The gap between the avatar and the ring is the sheet's
                    // own color showing through.
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ring ? colors.primary : colors.primary.clear,
                          width: _ring,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

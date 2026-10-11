import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';

/// The search input (C10 "SearchField"; board 1.12 "Arama"; UI guide §5 #11).
///
/// The frame of `AppTextField` (48 high, radius 12, 1 pt `borderControl`)
/// with a 20 pt MagnifyingGlass at the left (the text starts 44 from the edge)
/// and, while there is text, a 48 pt "Aramayı temizle" button with a 20 pt X.
/// The visible label is absent but the field is named for screen readers
/// ([semanticLabel], "Öğrenci ara"); [hintText] is the placeholder ("Program
/// ara").
///
/// Matching is the caller's, with `TurkishText` so Turkish letters meet their
/// plain forms (I, ı, İ, i; `TurkishText.matchesTokens` and `matchRanges`).
/// This field only reports the query: [onChanged] on every keystroke, and
/// [onQueryChanged] after the typing pauses for 150 ms
/// (`SmapDurations.searchDebounce`), trimmed, which is what a list filter
/// should listen to. Clearing reports at once. Highlight the matches with
/// `HighlightText`. With more than 50 records the search runs on the server
/// (the caller's decision).
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.semanticLabel,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onQueryChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.enabled = true,
    this.debounce = AppSearchField.defaultDebounce,
    super.key,
  });

  /// The accessible name ("Öğrenci ara").
  final String semanticLabel;

  /// The placeholder ("Program ara").
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Every keystroke, raw.
  final ValueChanged<String>? onChanged;

  /// The query once typing paused for [debounce], trimmed.
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool enabled;
  final Duration debounce;

  /// 150 ms (C10 "150 ms gecikme").
  static const Duration defaultDebounce = SmapDurations.searchDebounce;

  /// Width of the magnifier slot: 20 pt icon and 8 pt gap, after the 16 pt
  /// side padding (the text starts 44 from the edge).
  static const double _leadingSlot = 28;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _ownController;
  Timer? _timer;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_refresh);
      _controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_refresh);
    _ownController?.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _changed(String value) {
    widget.onChanged?.call(value);
    _timer?.cancel();
    _timer = Timer(widget.debounce, () {
      if (mounted) widget.onQueryChanged?.call(value.trim());
    });
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onQueryChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final hasText = _controller.text.isNotEmpty;
    return AppFieldFrame(
      semanticLabel: widget.semanticLabel,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      leading: SizedBox(
        width: AppSearchField._leadingSlot,
        child: Align(
          alignment: Alignment.centerLeft,
          child: PhosphorIcon(
            PhosphorIconsRegular.magnifyingGlass,
            size: AppSize.iconInButton,
            color: colors.textSecondary,
          ),
        ),
      ),
      trailing: hasText
          ? AppIconButton(
              icon: PhosphorIconsRegular.x,
              iconSize: AppSize.iconInButton,
              semanticLabel: l10n.kit_clearSearch,
              color: colors.textSecondary,
              onPressed: widget.enabled ? _clear : null,
            )
          : null,
      inputBuilder: (context, node, style, cursor) => TextField(
        controller: _controller,
        focusNode: node,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        onChanged: _changed,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        // Names and titles, not prose: no corrections over what was typed.
        autocorrect: false,
        enableSuggestions: false,
        style: style,
        cursorColor: cursor,
        decoration: bareFieldDecoration(
          hintText: widget.hintText,
          hintStyle: style.copyWith(color: colors.textPlaceholder),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/theme_context.dart';

/// The cover thumbnail of an exam (C24, C26; pano 1.16 "Deneme kartı", 5.3).
///
/// A [width] x [height] box with radius 8 (`AppRadius.sm`: the spec's 6 in
/// markup is dropped for the one cover radius), a `borderSubtle` fill and a
/// 22 pt `borderControl` book icon when the exam has no cover ("Kapak yoksa
/// nötr yer tutucu"). With a [url] the image is shown, and a failed load falls
/// back to the placeholder. Decoration: hidden from the screen reader.
class ExamCover extends StatelessWidget {
  const ExamCover({
    required this.width,
    required this.height,
    this.url,
    super.key,
  });

  /// 40 x 54 in a list row.
  const ExamCover.row({String? url, Key? key})
    : this(width: 40, height: 54, url: url, key: key);

  /// 48 x 64 in the exam detail header.
  const ExamCover.header({String? url, Key? key})
    : this(width: 48, height: 64, url: url, key: key);

  /// 56 x 76 in the result moment.
  const ExamCover.moment({String? url, Key? key})
    : this(width: 56, height: 76, url: url, key: key);

  final double width;
  final double height;

  /// The cover image; null draws the placeholder.
  final String? url;

  /// Edge of the placeholder icon.
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final placeholder = Center(
      child: PhosphorIcon(
        PhosphorIconsRegular.bookOpen,
        size: _iconSize,
        color: colors.borderControl,
      ),
    );
    final image = url;
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.borderSubtle,
            borderRadius: AppRadius.borderSm,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderSm,
            child: image == null
                ? placeholder
                : Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => placeholder,
                  ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/gen/assets.gen.dart';

/// The 11 clay pictures of the illustration set (C61 `SmapIllustration`;
/// board 1.25 "İllüstrasyon Seti ve Mevcut Varlıklar", Tur 12 delivery 11.18
/// "Kil görseller").
///
/// Each picture comes with its own pastel tile (corner 28/140); the file is
/// the whole picture, so nothing is added around it.
enum ClayPicture {
  /// Kitap: Türkçe.
  kitap,

  /// Hokka: Edebiyat, and the coach's "Henüz görüşme yok".
  hokka,

  /// Sütun: Tarih.
  sutun,

  /// Küre: Coğrafya.
  kure,

  /// İşlemler: Matematik. Store only (v1 opens Matematik on the web); it is
  /// an asset, no screen draws it.
  islemler,

  /// Piramit: Geometri. Store only, like [islemler].
  piramit,

  /// Atom: Fizik.
  atom,

  /// Erlenmeyer: Kimya.
  erlenmeyer,

  /// Yaprak: Biyoloji.
  yaprak,

  /// Ampul: Programım "Henüz programın yok".
  ampul,

  /// Harita: Denemelerim "Henüz deneme yok", the welcome screen, the deck of
  /// an exam, the store.
  harita;

  /// The generated asset of the picture (1x; `2.0x/` and `3.0x/` siblings are
  /// picked up by Flutter's resolution-aware loading once they are added).
  AssetGenImage get asset => switch (this) {
    ClayPicture.kitap => Assets.illustrations.clay.kitap,
    ClayPicture.hokka => Assets.illustrations.clay.hokka,
    ClayPicture.sutun => Assets.illustrations.clay.sutun,
    ClayPicture.kure => Assets.illustrations.clay.kure,
    ClayPicture.islemler => Assets.illustrations.clay.islemler,
    ClayPicture.piramit => Assets.illustrations.clay.piramit,
    ClayPicture.atom => Assets.illustrations.clay.atom,
    ClayPicture.erlenmeyer => Assets.illustrations.clay.erlenmeyer,
    ClayPicture.yaprak => Assets.illustrations.clay.yaprak,
    ClayPicture.ampul => Assets.illustrations.clay.ampul,
    ClayPicture.harita => Assets.illustrations.clay.harita,
  };

  /// The picture of a lesson (board 1.25: "Ders görselleri o dersin
  /// destesinde ve 'eksik yok' durumunda"). `null` for a lesson without one:
  /// Matematik and Geometri are web-only in v1, so their pictures are store
  /// assets and the empty state draws none; so does a lesson outside the
  /// catalog (`null` [subject]).
  static ClayPicture? forSubject(SubjectKey? subject) => switch (subject) {
    SubjectKey.turkce => ClayPicture.kitap,
    SubjectKey.edebiyat => ClayPicture.hokka,
    SubjectKey.tarih => ClayPicture.sutun,
    SubjectKey.cografya => ClayPicture.kure,
    SubjectKey.fizik => ClayPicture.atom,
    SubjectKey.kimya => ClayPicture.erlenmeyer,
    SubjectKey.biyoloji => ClayPicture.yaprak,
    SubjectKey.matematik || SubjectKey.geometri || null => null,
  };
}

/// The two edges of a clay picture (board 1.25 "Kurallar").
enum ClaySize {
  /// L 160 pt: onboarding.
  large(160),

  /// M 128 pt: screen-level empty states.
  medium(128);

  const ClaySize(this.edge);

  /// Edge in logical pixels.
  final double edge;
}

/// One clay picture (C61; board 1.25).
///
/// Rules of the set, which this widget keeps and the call sites must:
/// - used only on onboarding, in a screen-level empty state and in the store;
///   never in a row, a chip, a tab, a button or beside a chart; a
///   section-level empty state is text only (1.22);
/// - at most one per screen, with the title and one sentence under it;
/// - decoration: wrapped in `ExcludeSemantics`, the title carries the
///   meaning;
/// - the tile has its own corner and color: no border, no shadow, no second
///   container is added;
/// - the tile is the same in the dark theme: no inversion, tint, fade or
///   glow (the widget reads no theme);
/// - the file is the only source: while it is missing nothing is drawn, no
///   placeholder picture stands in for it.
class AppClay extends StatelessWidget {
  const AppClay(this.picture, {this.size = ClaySize.medium, super.key});

  /// M 128, the empty-state size.
  const AppClay.medium(this.picture, {super.key}) : size = ClaySize.medium;

  /// L 160, the onboarding size.
  const AppClay.large(this.picture, {super.key}) : size = ClaySize.large;

  final ClayPicture picture;
  final ClaySize size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: picture.asset.image(
        width: size.edge,
        height: size.edge,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
      ),
    );
  }
}

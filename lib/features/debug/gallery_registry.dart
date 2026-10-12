import 'package:flutter/widgets.dart';
import 'package:smap/features/debug/pages/buttons_gallery.dart';
import 'package:smap/features/debug/pages/choices_gallery.dart';
import 'package:smap/features/debug/pages/coach_gallery.dart';
import 'package:smap/features/debug/pages/controls_gallery.dart';
import 'package:smap/features/debug/pages/domain_gallery.dart';
import 'package:smap/features/debug/pages/feedback_gallery.dart';
import 'package:smap/features/debug/pages/identity_gallery.dart';
import 'package:smap/features/debug/pages/indicators_gallery.dart';
import 'package:smap/features/debug/pages/inputs_gallery.dart';
import 'package:smap/features/debug/pages/navigation_gallery.dart';
import 'package:smap/features/debug/pages/pickers_gallery.dart';
import 'package:smap/features/debug/pages/sheets_gallery.dart';
import 'package:smap/features/debug/pages/surfaces_gallery.dart';

/// One page of the component gallery: a tab title and the page body.
///
/// Every task that adds shared or domain components adds its own page here
/// (`xxx_gallery.dart` in `lib/features/debug/pages/`); the coordinator wires
/// it into [galleryPages]. A page is a plain widget that fills the scroll
/// area below the tab bar and reads the theme, text scale and motion
/// settings from the surrounding `MediaQuery` and `Theme`.
class GalleryPage {
  const GalleryPage({required this.title, required this.builder});

  /// The tab title ("Düğmeler").
  final String title;

  /// Builds the page body.
  final WidgetBuilder builder;
}

/// The pages of the gallery, in tab order. A simple list on purpose: adding a
/// page is one line.
final List<GalleryPage> galleryPages = [
  GalleryPage(title: 'Düğmeler', builder: (_) => const ButtonsGallery()),
  GalleryPage(
    title: 'Segment ve Sekme',
    builder: (_) => const ControlsGallery(),
  ),
  GalleryPage(
    title: 'Çipler ve Seçimler',
    builder: (_) => const ChoicesGallery(),
  ),
  GalleryPage(title: 'Girdiler', builder: (_) => const InputsGallery()),
  GalleryPage(title: 'Yüzeyler', builder: (_) => const SurfacesGallery()),
  GalleryPage(title: 'Göstergeler', builder: (_) => const IndicatorsGallery()),
  GalleryPage(title: 'Kimlik', builder: (_) => const IdentityGallery()),
  GalleryPage(title: 'Sheet', builder: (_) => const SheetsGallery()),
  GalleryPage(title: 'Durum', builder: (_) => const FeedbackGallery()),
  GalleryPage(title: 'Kabuk', builder: (_) => const NavigationGallery()),
  GalleryPage(title: 'Alan', builder: (_) => const DomainGallery()),
  GalleryPage(title: 'Program', builder: (_) => const PickersGallery()),
  GalleryPage(title: 'Koç', builder: (_) => const CoachGallery()),
];

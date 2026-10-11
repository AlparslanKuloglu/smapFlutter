import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/subject_tone.dart';

/// The Phosphor glyph of each subject (C58 `SubjectGlyph`; spec §3 "Ders
/// glifleri"; pano 1.5 and 1.17).
///
/// Pano 1.17 draws no subject icons of its own, so the spec's Phosphor names
/// are used as they are: TextAa, Feather, Bank, Globe, MathOperations, Angle,
/// Atom, Flask, Dna (Regular weight). Nothing here is an SVG or an image:
/// "ders satırında kil görsel değil glif kullanılır".
const Map<SubjectKey, IconData> subjectIcons = {
  SubjectKey.turkce: PhosphorIconsRegular.textAa,
  SubjectKey.edebiyat: PhosphorIconsRegular.feather,
  SubjectKey.tarih: PhosphorIconsRegular.bank,
  SubjectKey.cografya: PhosphorIconsRegular.globe,
  SubjectKey.matematik: PhosphorIconsRegular.mathOperations,
  SubjectKey.geometri: PhosphorIconsRegular.angle,
  SubjectKey.fizik: PhosphorIconsRegular.atom,
  SubjectKey.kimya: PhosphorIconsRegular.flask,
  SubjectKey.biyoloji: PhosphorIconsRegular.dna,
};

/// The glyph of a lesson that has no subject color: a neutral book.
const IconData subjectFallbackIcon = PhosphorIconsRegular.bookOpen;

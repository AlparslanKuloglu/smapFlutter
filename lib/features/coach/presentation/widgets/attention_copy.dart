import 'package:flutter/foundation.dart';

import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/coach/domain/attention_item.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The words of an attention row (C33; pano 10.1 kare 2) worked out from the
/// server's [AttentionItem]: the rule's sentence, the evidence line and the
/// one-sentence reading. A part the item has no data for is `null` and the
/// row does not draw it; nothing is made up.
///
/// - [AttentionRule.inactive]: "45 gündür deneme okutmadı" /
///   "Son deneme 17 Haz. 2026 · TYT".
/// - [AttentionRule.netDrop]: "Son iki TYT denemesinde net düştü" /
///   "68 → 66,75 · 17 Haz. ve 4 Ağu." (the net and the dates in the order the
///   server sent them: earlier exam first).
@immutable
class AttentionCopy {
  const AttentionCopy({
    required this.sentence,
    required this.semanticLabel,
    this.evidence,
  });

  /// The copy of [item] in Turkish.
  factory AttentionCopy.of(AppLocalizations l10n, AttentionItem item) =>
      switch (item.rule) {
        AttentionRule.inactive => _inactive(l10n, item),
        AttentionRule.netDrop => _netDrop(l10n, item),
      };

  /// The rule's sentence.
  final String sentence;

  /// The proof line; `null` without data for it.
  final String? evidence;

  /// The row read as one sentence: "Alparslan Kuloğlu, 45 gündür deneme
  /// okutmadı, son deneme 17 Haziran".
  final String semanticLabel;

  static AttentionCopy _inactive(AppLocalizations l10n, AttentionItem item) {
    // `AttentionItem.inactive` always carries the day count.
    final days = item.daysSinceLastExam ?? 0;
    final last = item.lastExamAt;
    final type = item.examType;
    final sentence = l10n.coachWidgets_attentionInactive(TrFormat.sira(days));
    if (last == null) {
      return AttentionCopy(
        sentence: sentence,
        semanticLabel: '${item.name}, $sentence',
      );
    }
    final date = TrFormat.kisaTarih(last, withYear: true);
    final tail = l10n.coachWidgets_attentionLastExamA11y(
      '${last.day} ${TrFormat.months[last.month - 1]}',
    );
    return AttentionCopy(
      sentence: sentence,
      evidence: type == null
          ? l10n.coachWidgets_attentionInactiveEvidence(date)
          : l10n.coachWidgets_attentionInactiveEvidenceType(date, type),
      semanticLabel: '${item.name}, $sentence, $tail',
    );
  }

  static AttentionCopy _netDrop(AppLocalizations l10n, AttentionItem item) {
    final type = item.examType;
    final sentence = type == null
        ? l10n.coachWidgets_attentionNetDropPlain
        : l10n.coachWidgets_attentionNetDrop(type);
    final from = item.previousNet;
    final to = item.latestNet;
    final firstDate = item.previousExamAt;
    final secondDate = item.latestExamAt;
    String? evidence;
    if (from != null && to != null) {
      final nets = (TrFormat.net(from), TrFormat.net(to));
      evidence = firstDate != null && secondDate != null
          ? l10n.coachWidgets_attentionNetEvidence(
              nets.$1,
              nets.$2,
              l10n.coachWidgets_attentionDates(
                TrFormat.kisaTarih(firstDate),
                TrFormat.kisaTarih(secondDate),
              ),
            )
          : l10n.coachWidgets_attentionNetEvidenceNets(nets.$1, nets.$2);
    }
    return AttentionCopy(
      sentence: sentence,
      evidence: evidence,
      semanticLabel: '${item.name}, $sentence',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AttentionCopy &&
      other.sentence == sentence &&
      other.evidence == evidence &&
      other.semanticLabel == semanticLabel;

  @override
  int get hashCode => Object.hash(sentence, evidence, semanticLabel);
}

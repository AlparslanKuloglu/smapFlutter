import 'package:flutter/foundation.dart';

import 'package:smap/shared/ui/feedback/section_state.dart';

/// The title block of Konu Detayı (pano 7.3 kare 1): the topic, the line
/// "Türkçe · TYT · 1. konu" and the counts "5 alt başlık · 25 madde".
@immutable
class TopicHeaderData {
  const TopicHeaderData({
    required this.topicName,
    required this.lessonName,
    required this.number,
    required this.subTopicCount,
    required this.itemCount,
    this.isLiterature = false,
    this.trackLabel,
  });

  final String topicName;

  /// The lesson's own name; [isLiterature] words it as "Türk Dili ve
  /// Edebiyatı".
  final String lessonName;
  final bool isLiterature;

  /// "TYT", "AYT", "SOS-2"; `null` when the topic was opened on "Tümü".
  final String? trackLabel;

  /// The topic's number in its lesson, 1 to n.
  final int number;
  final int subTopicCount;
  final int itemCount;

  @override
  bool operator ==(Object other) =>
      other is TopicHeaderData &&
      other.topicName == topicName &&
      other.lessonName == lessonName &&
      other.isLiterature == isLiterature &&
      other.trackLabel == trackLabel &&
      other.number == number &&
      other.subTopicCount == subTopicCount &&
      other.itemCount == itemCount;

  @override
  int get hashCode => Object.hash(
    topicName,
    lessonName,
    isLiterature,
    trackLabel,
    number,
    subTopicCount,
    itemCount,
  );
}

/// The content section of Konu Detayı: its state and the ids of the
/// sub-topics, in order (each card follows its own sub-topic).
@immutable
class TopicBodyData {
  const TopicBodyData(this.state, [this.subTopicIds = const []]);

  final SectionState state;
  final List<String> subTopicIds;

  @override
  bool operator ==(Object other) =>
      other is TopicBodyData &&
      other.state == state &&
      listEquals(other.subTopicIds, subTopicIds);

  @override
  int get hashCode => Object.hash(state, Object.hashAll(subTopicIds));
}

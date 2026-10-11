import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'package:smap/features/lessons/application/item_text.dart';
import 'package:smap/features/lessons/domain/lesson_content.dart';

/// What the student knows of an item's card (pano 7.3 "Eksik" tag).
enum ItemCardState {
  /// The server sent no status: nothing is drawn ("bilinmeyen kart durumu
  /// çizilmez").
  unknown,

  /// The item or one of its cards is missing: the amber "Eksik" tag.
  missing,

  /// Learned.
  learned,
}

/// An item (madde) of a sub-topic as Konu Detayı draws it (pano 7.3).
@immutable
class ItemView {
  const ItemView({
    required this.key,
    required this.number,
    required this.name,
    this.itemId,
    this.progressId,
    this.text = const ItemText(),
    this.card = ItemCardState.unknown,
    this.isFavorite = false,
  });

  /// Identifies the item inside the topic.
  final String key;

  /// The item's id (`_id`): what the star takes.
  final String? itemId;

  /// The progress record's id (`itemData._id`): what "Öğrendim" takes.
  final String? progressId;

  /// The number inside its sub-topic, 1 to n.
  final int number;
  final String name;
  final ItemText text;
  final ItemCardState card;
  final bool isFavorite;

  bool get isMissing => card == ItemCardState.missing;

  /// "Kartı Aç" is offered: the item has a card whose state is known.
  bool get hasCard => card != ItemCardState.unknown;

  /// "Öğrendim" can be sent: the card is missing and its record has an id.
  bool get canLearn =>
      isMissing && progressId != null && progressId!.isNotEmpty;

  /// Whether the favorite star can be pressed.
  bool get canFavorite => itemId != null && itemId!.isNotEmpty;

  ItemView copyWith({ItemCardState? card, bool? isFavorite}) => ItemView(
    key: key,
    number: number,
    name: name,
    itemId: itemId,
    progressId: progressId,
    text: text,
    card: card ?? this.card,
    isFavorite: isFavorite ?? this.isFavorite,
  );

  @override
  bool operator ==(Object other) =>
      other is ItemView &&
      other.key == key &&
      other.number == number &&
      other.name == name &&
      other.itemId == itemId &&
      other.progressId == progressId &&
      other.text == text &&
      other.card == card &&
      other.isFavorite == isFavorite;

  @override
  int get hashCode => Object.hash(
    key,
    number,
    name,
    itemId,
    progressId,
    text,
    card,
    isFavorite,
  );
}

/// A sub-topic (alt başlık): an accordion card of items (pano 7.3).
@immutable
class SubTopicView {
  const SubTopicView({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final String name;
  final List<ItemView> items;

  /// The items whose card is missing ("1 eksik").
  int get missingCount => items.where((item) => item.isMissing).length;

  SubTopicView withItems(List<ItemView> items) =>
      SubTopicView(id: id, name: name, items: items);

  @override
  bool operator ==(Object other) =>
      other is SubTopicView &&
      other.id == id &&
      other.name == name &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(items));
}

/// The first missing item of a topic: where the screen scrolls to on opening
/// (pano 7.3 "ilk eksik açık").
@immutable
class FocusTarget {
  const FocusTarget({required this.subTopicId, required this.itemKey});

  final String subTopicId;
  final String itemKey;

  @override
  bool operator ==(Object other) =>
      other is FocusTarget &&
      other.subTopicId == subTopicId &&
      other.itemKey == itemKey;

  @override
  int get hashCode => Object.hash(subTopicId, itemKey);
}

/// The content of one topic: its sub-topics and items (C50 `Accordion`, pano
/// 7.3). Pure and unit-tested.
@immutable
class TopicOutline {
  const TopicOutline(this.subTopics);

  /// Builds the outline from the sub-subjects `getSubjectContent` answered.
  /// A sub-subject without items is left out: there is nothing to open.
  factory TopicOutline.of(List<SubSubject> subSubjects) => TopicOutline([
    for (final sub in subSubjects)
      if (sub.items.isNotEmpty)
        SubTopicView(
          id: sub.id,
          name: sub.name,
          items: [
            for (final (index, item) in sub.items.indexed)
              _itemView(sub.id, index, item),
          ],
        ),
  ]);

  final List<SubTopicView> subTopics;

  bool get isEmpty => subTopics.isEmpty;

  /// All items of all sub-topics ("25 madde").
  int get itemCount => subTopics.fold(0, (sum, sub) => sum + sub.items.length);

  /// The first item whose card is missing; `null` when none is.
  FocusTarget? get firstMissing {
    for (final sub in subTopics) {
      for (final item in sub.items) {
        if (item.isMissing) {
          return FocusTarget(subTopicId: sub.id, itemKey: item.key);
        }
      }
    }
    return null;
  }

  /// The sub-topic that opens with the screen: the one with the first missing
  /// item, else the first.
  String? get initiallyOpenSubTopic =>
      firstMissing?.subTopicId ?? (isEmpty ? null : subTopics.first.id);

  ItemView? itemOf(String itemKey) {
    for (final sub in subTopics) {
      for (final item in sub.items) {
        if (item.key == itemKey) return item;
      }
    }
    return null;
  }

  /// The sub-topic holding [itemKey]; `null` for an unknown item.
  SubTopicView? subTopicOf(String itemKey) {
    for (final sub in subTopics) {
      if (sub.items.any((item) => item.key == itemKey)) return sub;
    }
    return null;
  }

  /// A copy where the item [itemKey] is changed by [change]; the other items
  /// are the same objects.
  TopicOutline withItem(String itemKey, ItemView Function(ItemView) change) =>
      TopicOutline([
        for (final sub in subTopics)
          if (sub.items.any((item) => item.key == itemKey))
            sub.withItems([
              for (final item in sub.items)
                item.key == itemKey ? change(item) : item,
            ])
          else
            sub,
      ]);

  @override
  bool operator ==(Object other) =>
      other is TopicOutline && listEquals(other.subTopics, subTopics);

  @override
  int get hashCode => Object.hashAll(subTopics);

  static ItemView _itemView(String subId, int index, LessonItem item) {
    final progress = item.progress;
    return ItemView(
      key: '$subId:$index',
      number: index + 1,
      name: item.name,
      itemId: item.id,
      progressId: progress?.id,
      text: ItemTextParser.parse(item.descriptions),
      card: cardStateOf(progress),
      isFavorite:
          item.isFavorite || item.prompts.any((prompt) => prompt.isFavorite),
    );
  }

  /// The card state of a progress record: missing when the item or one of
  /// its cards is, learned when a status says so, otherwise unknown.
  static ItemCardState cardStateOf(ItemProgress? progress) {
    if (progress == null) return ItemCardState.unknown;
    if (progress.hasMissing) return ItemCardState.missing;
    if (progress.status == 1 || progress.statusArray.isNotEmpty) {
      return ItemCardState.learned;
    }
    return ItemCardState.unknown;
  }
}

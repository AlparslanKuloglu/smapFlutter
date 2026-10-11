import 'package:flutter/foundation.dart' show immutable, listEquals;

/// One topic card under a question (board 5.6 "Soru Detay"): the main subject
/// it belongs to, its title and its text.
@immutable
class QuestionTopicCard {
  const QuestionTopicCard({
    required this.title,
    this.mainSubjectName,
    this.paragraphs = const [],
  });

  /// The card's own title ("Yavuz Selim Dönemi").
  final String title;

  /// The main subject's name ("Osmanlı Tarihi"); `null` when the server did not
  /// populate it.
  final String? mainSubjectName;

  /// The card text, paragraph by paragraph.
  final List<String> paragraphs;

  /// The text as one block (the legacy screen joined paragraphs with a space).
  String get text => paragraphs.join(' ');

  @override
  bool operator ==(Object other) =>
      other is QuestionTopicCard &&
      other.title == title &&
      other.mainSubjectName == mainSubjectName &&
      listEquals(other.paragraphs, paragraphs);

  @override
  int get hashCode =>
      Object.hash(title, mainSubjectName, Object.hashAll(paragraphs));
}

/// What `getQuestion` says about one question: what it asks, where it sits on
/// the form and the topic cards behind it.
@immutable
class QuestionDetail {
  const QuestionDetail({
    this.description,
    this.pageInfo,
    this.cards = const [],
  });

  /// "Bu soru 1. Kosova Savaşı'nın ... yorumlamanı istedi."
  final String? description;

  /// Where the question is on the optical form (`page_info`).
  final String? pageInfo;

  final List<QuestionTopicCard> cards;

  @override
  bool operator ==(Object other) =>
      other is QuestionDetail &&
      other.description == description &&
      other.pageInfo == pageInfo &&
      listEquals(other.cards, cards);

  @override
  int get hashCode => Object.hash(description, pageInfo, Object.hashAll(cards));
}

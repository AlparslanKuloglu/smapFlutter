import 'package:flutter/foundation.dart';

import 'package:smap/shared/ui/feedback/section_state.dart';

/// The title block of the era detail (pano 14.5 kare 2): the era's name and
/// the tag "2 eksik eser". The name is `null` while the era list has not
/// told it.
@immutable
class EraHeaderData {
  const EraHeaderData({this.name, this.missing});

  final String? name;

  /// Missing works under the era; `null` or zero draws no tag.
  final int? missing;

  @override
  bool operator ==(Object other) =>
      other is EraHeaderData && other.name == name && other.missing == missing;

  @override
  int get hashCode => Object.hash(name, missing);
}

/// The section under the title: its state and the ids of the sub-subjects, in
/// the server's order (each accordion follows its own sub-subject).
@immutable
class EraBodyData {
  const EraBodyData(this.state, [this.subIds = const []]);

  final SectionState state;
  final List<String> subIds;

  @override
  bool operator ==(Object other) =>
      other is EraBodyData &&
      other.state == state &&
      listEquals(other.subIds, subIds);

  @override
  int get hashCode => Object.hash(state, Object.hashAll(subIds));
}

/// The header of one accordion (pano 14.5 kare 2): the name, the tag "2
/// eksik" and whether it is open.
@immutable
class SubCardData {
  const SubCardData({
    required this.id,
    required this.name,
    required this.open,
    this.missing,
  });

  final String id;
  final String name;
  final bool open;
  final int? missing;

  @override
  bool operator ==(Object other) =>
      other is SubCardData &&
      other.id == id &&
      other.name == name &&
      other.open == open &&
      other.missing == missing;

  @override
  int get hashCode => Object.hash(id, name, open, missing);
}

/// What an author row of an open accordion draws.
@immutable
class AuthorRowData {
  const AuthorRowData({
    required this.key,
    required this.name,
    required this.workCount,
    required this.missing,
    this.photo,
  });

  final String key;
  final String name;
  final int workCount;
  final int missing;
  final String? photo;

  @override
  bool operator ==(Object other) =>
      other is AuthorRowData &&
      other.key == key &&
      other.name == name &&
      other.workCount == workCount &&
      other.missing == missing &&
      other.photo == photo;

  @override
  int get hashCode => Object.hash(key, name, workCount, missing, photo);
}

/// The inside of an accordion: three skeleton rows while the authors load, the
/// rows, "Bu bölümde yazar yok." when there are none, or the error with "Tekrar
/// Dene" (pano 14.5 kare 3, 14.7 kare 2).
@immutable
class SubAuthorsData {
  const SubAuthorsData(this.state, [this.rows = const []]);

  final SectionState state;
  final List<AuthorRowData> rows;

  @override
  bool operator ==(Object other) =>
      other is SubAuthorsData &&
      other.state == state &&
      listEquals(other.rows, rows);

  @override
  int get hashCode => Object.hash(state, Object.hashAll(rows));
}

/// What the page scrolls to once its accordions are on screen.
@immutable
class EraFocusTarget {
  const EraFocusTarget(this.subId);

  final String subId;
}

import 'package:flutter/foundation.dart';

import 'package:smap/features/coach/data/dtos/interview_dtos.dart';

/// One page of `InterviewRepository.getInterviews`.
@immutable
class InterviewPage {
  const InterviewPage({
    required this.items,
    required this.page,
    required this.limit,
  });

  /// The interviews of this page, newest first as the server sorts them.
  final List<InterviewDto> items;

  /// The 1-based page number that was asked for.
  final int page;

  /// The page size that was asked for.
  final int limit;

  /// Whether another page may follow. The server sends no total or "next"
  /// marker (spec §6.3 #31), so, like the legacy screen, a full page means
  /// "maybe more" and a short one means "end". One extra empty request is the
  /// price when the total is an exact multiple of [limit].
  bool get hasMore => items.length >= limit;
}

import 'package:flutter/foundation.dart';

import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';

/// What `ScheduleRepository.getWeeklies` answers: the programs and the bag.
@immutable
class WeekliesResponse {
  const WeekliesResponse({this.weeklies = const [], this.bagItems = const []});

  /// The programs, in server order.
  final List<WeeklyDto> weeklies;

  /// The student's "Çantam".
  final List<BagItemDto> bagItems;
}

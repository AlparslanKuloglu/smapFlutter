import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// Today in the boards: Cumartesi 10 Ekim 2026.
final DateTime kToday = DateTime(2026, 10, 10);

const String kTurkceId = '663e37a24fb443839593141b';
const String kTytTarihId = '66214a6982ff212039ea3294';
const String kTytCografyaId = '6660eec58cf59b23d04006b4';

/// The three topics of pano 3.4 kare 3 as stored on the server.
Map<String, Object?> ekimIkinciHaftaJson({String id = 'w-ekim-2'}) => {
  '_id': id,
  'name': 'Ekim 2. Hafta',
  'motto': 'Her gün biraz daha',
  'content': [
    {
      'id': 't1',
      'day': '2026-10-10',
      'hour': 10,
      'minute': 0,
      'lesson': kTurkceId,
      'lessonName': 'TYT Türkçe',
      'mainSubject': 'm-turkce',
      'title': 'Fiilde Çatı',
    },
    {
      'id': 't2',
      'day': '2026-10-10',
      'hour': 14,
      'minute': 0,
      'lesson': kTytTarihId,
      'lessonName': 'TYT Tarih',
      'mainSubject': 'm-tarih',
      'title': 'Kurtuluş Savaşı Hazırlık Dönemi',
    },
    {
      'id': 't3',
      'day': '2026-10-10',
      'hour': 20,
      'minute': 0,
      'lesson': kTytCografyaId,
      'lessonName': 'TYT Coğrafya',
      'mainSubject': 'm-cografya',
      'title': 'İklim Bilgisi',
    },
  ],
};

WeeklyDto ekimIkinciHafta({String id = 'w-ekim-2'}) =>
    WeeklyDto.fromJson(ekimIkinciHaftaJson(id: id));

WeeklyDraft ekimIkinciHaftaDraft() => ekimIkinciHafta().toDraft();

/// Test helper: the same entry under another id.
extension ProgramEntryTestX on ProgramEntry {
  ProgramEntry copyId(String newId) => ProgramEntry(
    id: newId,
    day: day,
    hour: hour,
    minute: minute,
    lessonId: lessonId,
    lessonName: lessonName,
    title: title,
    subject: subject,
    mainSubjectId: mainSubjectId,
  );
}

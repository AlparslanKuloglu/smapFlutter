import 'package:smap/core/utils/turkish_text.dart';

/// How a `POST /student/register` that the server understood ended.
///
/// Anything else (a refusal with some other text, no connection, a 5xx) is an
/// `AppException`; this enum only holds the two answers a form can act on.
enum RegisterOutcome {
  /// The account exists. The caller signs in with the same credentials.
  registered,

  /// The user name is in use (pano 2.6 kare 1 "Bu kullanıcı adı alınmış.").
  userNameTaken;

  /// Whether a refusal text from the server says the user name is in use.
  ///
  /// The register endpoint has no flag for it (the coach's `addNewStudent`
  /// answers `userNameUsing: true`), so the text decides: it must name the
  /// user name and say it is taken ("kullanıcı adı zaten kullanımda"). Case
  /// and Turkish marks do not matter. Spec §6.3 #12 keeps the real contract
  /// open.
  static bool readsAsUserNameTaken(String? serverMessage) {
    if (serverMessage == null) return false;
    final text = TurkishText.fold(serverMessage);
    const subjects = [
      'kullanici adi',
      'kullanici ismi',
      'username',
      'user name',
    ];
    const states = [
      'alinmis',
      'kullanimda',
      'kullaniliyor',
      'kullanilmis',
      'mevcut',
      'zaten',
      'kayitli',
      'taken',
      'exists',
      'already',
      'in use',
    ];
    return subjects.any(text.contains) && states.any(text.contains);
  }
}

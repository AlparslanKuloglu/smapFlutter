/// The mail draft of "Bize Yaz" (pano 9.1 kare 2 "E-posta uygulaman açılır";
/// spec §4.H: "taslak sürüm ve cihaz bilgisiyle dolar").
///
/// A `mailto:` link whose subject and body are percent-encoded the way mail
/// apps read them (a space is `%20`, not `+`, and a line break is CRLF).
/// Pure and unit-tested.
abstract final class SupportMail {
  /// The link that opens a draft to [address].
  ///
  /// [subject] is the subject line; [details] are lines under an empty space
  /// for the person's own text ("Uygulama sürümü: 3.0.0 (300)"). Empty
  /// [subject] or [details] are left out.
  static Uri compose({
    required String address,
    required String subject,
    List<String> details = const [],
  }) {
    final query = <String>[
      if (subject.trim().isNotEmpty) 'subject=${_encode(subject)}',
      if (details.isNotEmpty) 'body=${_encode(_body(details))}',
    ];
    return Uri(
      scheme: 'mailto',
      path: address.trim(),
      query: query.isEmpty ? null : query.join('&'),
    );
  }

  /// Two empty lines for the person, then the details.
  static String _body(List<String> details) => '\n\n\n${details.join('\n')}\n';

  static String _encode(String text) => Uri.encodeComponent(
    text.replaceAll('\r\n', '\n').replaceAll('\n', '\r\n'),
  );
}

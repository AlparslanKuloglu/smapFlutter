import 'package:stacked/stacked.dart';

import 'package:smap/features/account/application/legal_entries.dart';

/// The logic of the reading screen of one legal text (pano 9.7 kare 2; route
/// `/account/agreements/read`).
///
/// The text arrives with the route (the list already loaded every document),
/// so there is nothing to wait for: the screen shows the title, the version
/// and the text as HTML in the app's reading type. Plain text a document may
/// carry is turned into paragraphs first (`LegalReading.htmlOf`).
class ContractReaderViewModel extends BaseViewModel {
  ContractReaderViewModel({required this.entry})
    : html = LegalReading.htmlOf(entry.document.content);

  /// The text being read.
  final LegalEntry entry;

  /// The text as HTML; empty when the document has none.
  final String html;

  /// Whether there is anything to read.
  bool get hasText => html.isNotEmpty;
}

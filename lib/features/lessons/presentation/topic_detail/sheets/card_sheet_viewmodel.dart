import 'package:stacked/stacked.dart';

/// The star of the card sheet (pano 7.3 kare 3): it flips at once and goes
/// back when the request fails.
///
/// [onFavorite] sends the new value (`addFavoriteMobil`) and answers whether
/// it was saved. A second press while the first is on its way is ignored.
class CardSheetViewModel extends BaseViewModel {
  CardSheetViewModel({
    required bool isFavorite,
    required this.canFavorite,
    required Future<bool> Function(bool favorite) onFavorite,
  }) : _isFavorite = isFavorite,
       _onFavorite = onFavorite;

  final Future<bool> Function(bool favorite) _onFavorite;

  /// The item has an id the star can be sent for.
  final bool canFavorite;

  bool _isFavorite;
  bool _sending = false;
  bool _disposed = false;

  /// The star is filled.
  bool get isFavorite => _isFavorite;

  /// Flips the star, sends it, and puts it back if it was not saved.
  Future<void> toggleFavorite() async {
    if (!canFavorite || _sending) return;
    final next = !_isFavorite;
    _sending = true;
    _isFavorite = next;
    notifyListeners();
    final saved = await _onFavorite(next);
    _sending = false;
    if (_disposed) return;
    if (!saved) {
      _isFavorite = !next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

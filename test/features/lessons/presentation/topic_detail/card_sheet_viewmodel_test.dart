import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/lessons/presentation/topic_detail/sheets/card_sheet_viewmodel.dart';

void main() {
  late List<bool> sent;
  late CardSheetViewModel viewModel;
  var answer = true;
  Completer<void>? gate;

  setUp(() {
    sent = [];
    answer = true;
    gate = null;
    viewModel = CardSheetViewModel(
      isFavorite: false,
      canFavorite: true,
      onFavorite: (favorite) async {
        sent.add(favorite);
        await gate?.future;
        return answer;
      },
    );
  });

  tearDown(() => viewModel.dispose());

  test('the star flips at once and is sent', () async {
    final done = viewModel.toggleFavorite();
    expect(viewModel.isFavorite, isTrue);
    await done;

    expect(viewModel.isFavorite, isTrue);
    expect(sent, [true]);
  });

  test('a star that was not saved goes back', () async {
    answer = false;

    await viewModel.toggleFavorite();

    expect(viewModel.isFavorite, isFalse);
  });

  test('a second press while the first is on its way is ignored', () async {
    gate = Completer<void>();

    final first = viewModel.toggleFavorite();
    await viewModel.toggleFavorite();
    gate!.complete();
    await first;

    expect(sent, [true]);
  });

  test('an item without an id has no star to press', () async {
    final noId = CardSheetViewModel(
      isFavorite: false,
      canFavorite: false,
      onFavorite: (favorite) async {
        sent.add(favorite);
        return true;
      },
    );

    await noId.toggleFavorite();

    expect(sent, isEmpty);
    expect(noId.isFavorite, isFalse);
    noId.dispose();
  });

  test('starts from the item\'s own star and can be taken back', () async {
    final starred = CardSheetViewModel(
      isFavorite: true,
      canFavorite: true,
      onFavorite: (favorite) async {
        sent.add(favorite);
        return true;
      },
    );

    await starred.toggleFavorite();

    expect(starred.isFavorite, isFalse);
    expect(sent, [false]);
    starred.dispose();
  });
}

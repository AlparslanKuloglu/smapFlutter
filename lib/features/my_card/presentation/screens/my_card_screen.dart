import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Veya projedeki DI yapısı
import 'package:smap/features/my_card/presentation/screens/my_cards_page/my_card_page/my_card_page.dart';

import 'package:smap/repository/cards_repository.dart';

class MyCardScreen extends StatelessWidget {
  const MyCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Repository referansını context'ten veya servis bulucudan (GetIt vb.) alıyoruz
    final myCardRepository = context.read<CardsRepository>();

    // Repository'yi doğrudan alt sayfaya paslıyoruz, işlem çekme/tetikleme burada yok
    return MyCardPage(repository: myCardRepository);
  }
}

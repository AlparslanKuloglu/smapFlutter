# SMAP (Student Map)

YKS'ye hazırlanan öğrenciler ve öğrenci koçları için Flutter uygulaması: deneme optik formunu okutma, sonuç ve analiz, dersler ve bilgi kartları, haftalık program, koç–öğrenci takibi.

## Hızlı başlangıç

Flutter 3.38.6 (stable) gerekir.

```bash
flutter pub get
```

```bash
cp config/dev.json.example config/dev.json
```

```bash
flutter run --dart-define-from-file=config/dev.json
```

Hesap açmadan arayüzü görmek için `--dart-define=SHELL_PREVIEW=student` (ya da `coach`); bileşen galerisi için `flutter run -t lib/main_gallery.dart`.

## Belgeler

- [docs/DEVELOPING.md](docs/DEVELOPING.md): geliştirici rehberi (buradan başlayın)
- [AGENTS.md](AGENTS.md): bağlayıcı kurallar (geliştiriciler ve yapay zekâ ajanları için)
- [docs/WORKFLOW.md](docs/WORKFLOW.md): çalışma modeli (görev, worktree, inceleme, entegrasyon)
- [docs/design/README.md](docs/design/README.md): tasarım panoları ve görseller
- [docs/DURUM.md](docs/DURUM.md): durum ve açık işler

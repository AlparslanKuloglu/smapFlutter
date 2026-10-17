# SMAP Redesign — Durum

Durum: ⏳ bekliyor · 🔨 ajanda · 🔎 incelemede · 🔁 iade · ✅ merge · ⛔ bloke
Plan: `docs/SMAP_Ana_Plan.md` · Backend ek soruları: `docs/Backend_Sorulari_Ek.md` · Entegrasyon dalı: `redesign/main` (yerel)

Baseline (2026-10-11): `flutter analyze` 307 sorun (0 hata), test: kırık `widget_test.dart`.
Şimdi (redesign/main d8da851): ThemeMode.system; **flutter analyze 0 sorun**, 3347 test yeşil, iOS + Android debug derleniyor. Eski kod tamamen silindi (FIN2); her ekran yeni. CI: analiz (bilgi düzeyi dahil) + tool/ui_rules.sh.

| ID | Görev | Dalga | Durum | Dal | Not |
|---|---|---|---|---|---|
| G0 | Repo hazırlığı | 0 | ✅ | redesign/main | `main` a0c7d83 yerel değişiklikler; db1b360 AGENTS.md + tool/wt.sh |
| G1 | Bağımlılık ve iskelet | 0 | ✅ | 568b634 | SDK 3.10.7, 15 paket, font, l10n, CI; analyze 314 (SDK kaynaklı +1 dead_code kabul) |
| INF1 | Çekirdek altyapı | 1A | ✅ | 51d4f27 | AppConfig, AppException, NetworkService (çerez, 302/401), DI; 141 test. Açık: 403'ün oturum bitti sayılması (varsayılan {401,403}) backend cevabına bağlı |
| TOK | Token'lar ve tema | 1A | ✅ | 677fde7 | 11.12 değerleri birebir doğrulandı; SmapTheme, TrFormat, TurkishText, haptik köprüsü; 636 test |
| CLN | Ölü kod ve sahte giriş | 1A | ✅ | beb67e1 | 40 dosya silindi (grep kanıtlı) + 4 ek ölü dosya (koordinatör); login/register prefill kaldırıldı |
| KIT1 | Kit-1 + galeri | 1B | ✅ | 6ad4260 | 40+ bileşen, galeri (main_gallery.dart), 8 logo SVG; simülatörde 1.9/1.10 ile karşılaştırıldı. Not: pasif segment görünümü belirgin değil (E görevinde düzeltilecek) |
| SES | Oturum ve auth verisi | 1B | ✅ | 0724094 | SessionManager, AuthRepository, UserDto (password yok), secure storage göçü; legacy user_data aynası açık (kMirrorLegacyUserData=true) |
| KIT2 | Kit-2 katmanlar/durumlar | 1C | ✅ | redesign/main | sheet/onay/toast/iskelet/boş/hata/durum/çevrimdışı, SelectField, TimeWheel (limit sonrası WIP'ten devam) |
| DOM | Alan bileşenleri | 1C | ✅ | redesign/main | D/Y/B, QuestionCell, Exam*, NetChart, Subject*, EksikTag, ProgramItemRow, InfoCardFace; 1.14 ile simülatörde birebir. AppSuccessRing %100 taşması koordinatör düzeltti |
| RTR | Router, bootstrap, tema | 1D | ✅ | e994017 | auto_route 11.1.0 (11.2 Flutter 3.38'de derlenmiyor), guard zinciri, native splash, SessionExpiredSheet, legacy köprüsü; simülatörde açılış→tanıtım→giriş doğrulandı. Gerçek hesapla giriş/çıkış henüz denenmedi |
| DATA1 | Veri: deneme/analiz/ders/kart | 1D | ✅ | 290a439 | Exam/Analytics/LessonContent/Card repo + LessonsService; 10 backend sorusu raporda |
| DATA2 | Veri: program/hesap/koç | 1D | ✅ | d72454d | Schedule/Account/CoachStudent/Interview repo + servisler; StudyTrack/SchoolGrade tek eşleme; görüşme tarihi legacy biçimine döndürüldü (koordinatör) |
| KIT3 | Kabuk parçaları | 1C | ✅ | redesign/main | RootBand/HomeBand/DetailBar/ContextStrip/BottomBar/CameraButton/StudentScope |
| E1 | Açılış + genel ekranlar | 2A | ✅ | e994017 (RTR içinde) | 2.7'nin 4 karesi RTR'de tamamlanmış (metinler birebir); zorunlu güncelleme/bakım public-config ucu gelene kadar kapalı; "Destek'e Yaz" supportEmail yokken gizli |
| E2 | Tanıtım, rol, sınıf, kamera ön, hoş geldin | 2A | ✅ | f7db7c9 | simülatörde 2.1/2.2 ile karşılaştırıldı. Açık: Dil çipi pasif (kodu yok), kil Harita 3x dosyası bekleniyor |
| E3 | Giriş + şifremi unuttum (flag) | 2A | ✅ | 659034c | feature_flags.dart; şifremi unuttum ve sosyal giriş kapalı |
| E4 | Kayıt | 2A | ✅ | ed0355b | simülatörde 2.5 ile karşılaştırıldı; gerçek kayıt gönderilmedi (backend sorusu: accepted*Version alanları) |
| E5 | Kabuk | 2A | ✅ | 6894dae | öğrenci/koç sekme yığınları, sekmeler legacy ekranları sarıyor; SHELL_PREVIEW debug önizlemesi |
| E6 | Anasayfa | 2C | ✅ | 00cf807 | sekme yeni ekranda; Ders/Konu/Programım bağlantıları yeni route'lara bağlandı (koordinatör); Deneme Detay hâlâ legacy (E10) |
| E7 | Programım | 2C | ✅ | 00cf807 | liste/gün/hafta/yeni program/düzenle; program silme flag'li (uç yok); eski my_schedule_page koç ekranları yüzünden duruyor |
| E11 | Analizlerim | 2C | ✅ | 00cf807 | Genel + Denemelerim; favori cihazda; sıralama ucu yok |
| E12 | Derslerim ve konular | 2C | ✅ | 00cf807 | Derslerim/Ders/Konu/Edebiyat yazar-eser (Tur 12 C); 2.652 satırlık eski sayfa silindi |
| E10 | Deneme Detay + Soru Detay | 2D | ✅ | c8978b3 | Deneme Detay/Soru Detay yeni; soru şıkları backend'de yok (yalnız durum); deneme kartları listelenemiyor (yalnız sayı) |
| E13 | Kart Destesi | 2D | ✅ | c8978b3 | deste; Öğrendim için uçsuz 6 sn bekletmeli Geri Al |
| E14a | Hesap, Profil, Sözleşmeler | 2D | ✅ | c8978b3 | Hesap/Profil/Sözleşmeler; ödeme, kayıtlı kart ve fatura mock'ları silindi |
| E14b | Şifre, Hesabı Sil, Koçluk, Bildirimler | 2D | ✅ | c8978b3 | Şifre (flag kapalı), Hesabı Sil, Koçluk (Tur 12 F/G), Bildirimler (cihazda, flag) |
| E8 | Kamera ve optik okuma | 2E | ✅ | a23e091 | tek route'lu akış (/scan), kapı ScanEntry; eski OMR (lib/views, omd_repository, http_service) silindi. Açık: OMR host (#1), answersArray biçimi, bakım ucu (#4); gerçek kamera cihazda denenmedi |
| E9 | Sonuç anı | 2E | ✅ | a23e091 | 5.1 birebir; bildirim izni sheet'i bayrak arkasında (notificationsEnabled=false). Fark, listedeki önceki aynı tür denemeden |
| E15 | Koç Anasayfa | 2F | ✅ | a23e091 | Dikkat gerektirenler bayrakta (uç yok, #28/#29); görüşme saatleri duvar saati kuralına çekildi (koordinatör) |
| E16 | Öğrencilerim + Öğrenci Ekle | 2F | ✅ | a23e091 | Tur 12 D avatar seçimi; eski my_students silindi. Açık: Dil alanı kodu, seasonType 13 |
| E18 | Görüşmeler ve notlar | 2F | ✅ | a23e091 | not silme 6 sn bekletmeli; görüşme düzenle/sil ucu yok; eski my_interviews silindi |
| E17 | Öğrenci Profili (koç) | 2G | ✅ | 80e4a6c | 10.4 dört kare; Program sekmesinde yazma açık (Tur 12 A); NewMeetingFlow ortak. AÇIK: koç oturumu studentId'li uçları kabul ediyor mu, koçun yazması öğrencinin hesabına işleniyor mu (gerçek hesapla doğrulanmadı) |
| E19 | Koç için Okut | 2G | ⛔ | | eski OMR akışı da studentId göndermiyor (omd_repository) — backend #34 cevabı gelene kadar yapılmayacak |
| FIN3 | Marka varlıkları | 3 | ✅ | 6c05f74 | S-rota ikonu (iOS açık/koyu/tinted, Android uyarlanabilir), bildirim ikonu, Android 12 açılış ölçüsü, ad "SMAP". AÇIK: kullanılmayan 90 görselin (14,5 MB) silinmesi kullanıcı onayı bekliyor — liste docs/gorevler/fin3_kullanilmayan_gorseller.txt; kil illüstrasyonların 3x dosyaları tasarımdan istenecek |
| FIN2 | Eskiyi silme | 3 | ✅ | 29e8798 | LegacyScope/Provider katmanı, lib/repository, lib/domain, AppColors/AppTheme, DioClient, 9 kullanılmayan paket; user_data aynası kapalı; katı lint köke alındı |
| FIN1+FIN4 | Koyu tema + erişilebilirlik | 3 | ✅ (FIN14E d8da851) | A 2dd31bc, D ebe65a2, C f914bdb, B 213a9e1; ThemeMode.system | B: hafta ızgarası, saat dilimi, ders/konu satırları ve SubjectTile 1,35'te; kart destesi ve konu maddesi tek okunuş. FIN14E: AppHomeBand, AppBottomBar etiketleri, AppDayChip, AppAccordion özeti. Karar bekleyen: hafta ızgarası blokları 36 dp (pano C63); C: C: grafik eksen etiketleri ve balon 1,35 ölçekte, Form Kontrol ve Sonuç Anı düğmeleri ölçekleniyor, soru hücresi okunuşu, köşe ipucu okuma sırası; A: giriş logosu koyu, açılış ekranları sarı alt çizgi, tanıtım 1,35 taşması; D: kabukta alt çubuk 34 pt eksik hesaplanıyordu (bütün sekmeler), AppCard tek okunuş, AppSegmented 48 dp, AppLockup koyu, AppSpinner. Bilinen sınır: hareketi azalt'ta sayfa geçişi platform kaydırması (iOS geri kaydırma korunuyor) |
| FIN5 | Yayın hazırlığı | 3 | ⛔ | | sahip kararları: uygulama kimliği, imza, sürüm; mağaza görselleri |
| T12 | Tur 12 brifi (K12 denetimi) | – | ✅ | – | `docs/SMAP_Tasarim_Brifi_Tur12.md`; 7 özellik geri geliyor (A–G); sahte/yakında olanlar düşüyor; denetim `docs/K12_Denetim.json`. Tasarım bekleniyor (SMAP-14.html) |

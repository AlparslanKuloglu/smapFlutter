# SMAP (smapFlutter) Görsel Dil Raporu

Kapsam: `.`, salt okunur inceleme. `lib/vendor/` atlandı. O klasör `flutter_document_scanner` v1.1.1, yani üçüncü taraf kamera/kırpma eklentisidir (45 dart dosyası). Kısaltmalar: `A` = `lib/features/analytics/presentation`, `H` = `lib/features/home/presentation`, `R` = `lib/features/root/presentation`, `C` = `lib/features/my_card/presentation`, `P` = `lib/features/profile/presentation`, `AU` = `lib/features/auth/presentation`, `V` = `lib/views/optic_mark_detection_view`.

Yasaklı dosyalara (key.properties, keystore, google-services.json, GoogleService-Info.plist, .env, `*-Files`) dokunmadım.

---

## 0. Tek paragraf özet (tasarımcı için)

Kodun gerçek görsel DNA'sı şu:

- Koyu lacivert başlık bandı, alt köşeleri 32 yarıçaplı.
- Beyaz gövde ve hafif gri (#F5F7F9) kartlar.
- Turuncu vurgu: aktif sekme, kamera butonu, "bugün" günü, ilerleme çubuğu.
- Kart kenarlarında ince gri çizgi ve çok hafif gölge.
- Düz (flat) çizim ikonlar.
- Font ailesi tanımlı değil, sistem fontu (Roboto / SF) kullanılıyor.
- Tema yalnızca açık (light-only).

Asıl sorun renk, yarıçap, boyut ve bileşenlerde **token sisteminin fiilen çalışmaması**. Merkezi `AppColors` sınıfında 17 renk var. Buna karşılık dosyalara dağılmış 424 `Color(0x…)` literali (153 farklı hex), ~600 `Colors.*` kullanımı ve 22 farklı köşe yarıçapı değeri var. Aynı bileşen (ör. TYT/AYT segment kontrolü) her ekranda farklı turuncu, gri ve yarıçapla yeniden yazılmış. Tasarım "değiştirilmeden evrilecekse" yapılması gereken şey yeni görünüm icat etmek değil, bu dağınıklığı tek bir token setine toplamak.

---

## 1. Palet

### 1.1 Merkezi tanımlar (`lib/core/theme/app_colors.dart`)

| Token | Hex | Satır | Kullanım (ref sayısı) ve yer |
|---|---|---|---|
| `primaryOrange` | #FF6600 | :6 | 96. Aktif nav ikon/etiket, sekme seçili, "bugün" halkası, kamera FAB, ilerleme dolgusu, stat kartı alt kenarı |
| `background` | #FFFFFF | :9 | 17. Scaffold ve gövde |
| `menuCardBackground` | #F5F7F9 | :12 | 25. Takvim kartı, test sonucu kartı, segment tepsisi |
| `white` | #FFFFFF | :14 | 81 |
| `textPrimary` | #1C1F33 | :15 | 71. Ana metin |
| `textSecondary` | #8A90A6 | :16 | 48. İkincil metin |
| `shadowLight` | #000 α8% (0x14) | :17 | 13. Kart gölgesi |
| `shadowMedium` | #000 α8.6% (0x16) | :18 | 6. Neredeyse aynı, gereksiz ikinci token |
| `orangeShadow` | #FF8A00 α20% | :19 | 3. Kamera butonu gölgesi |
| `navUnselected` | #B2BAC6 | :20 | 9. Pasif nav |
| `navSelectedBg` | #FFD4B3 | :21 | 11. Nav seçili hap arka planı, "bugün" dolgusu, avatar arka planı |
| `navIndicator` | #FF7A00 | :22 | 1. Nav üst çubuğu (`custom_bottom_nav_bar.dart:80`). İkon/etiket ise #FF6600 |
| `appBarBackground` | #0F294A | :23 | 66. Kodun "resmî" laciverti |
| `unselectedGrey` | #E2E8F0 | :24 | 8. İlerleme çubuğu rayı, TabBar pasif |
| `accentOrange` | #FF8A00 | :25 | 8. TabBar seçili etiketi (`question_detail_page.dart:~215`) |
| `appBarBlueGrey` | #7D858D | :26 | 5. Tema seed'i ve snackbar |

`hexToColor` (:38-60) sunucudan gelen hex'i parse eder. Hata durumunda fallback rengi `Color.fromARGB(255,232,234,235)` yani #E8EAEB'dir.

### 1.2 Tema (`lib/core/theme/app_theme.dart`)

- `useMaterial3: true`, `ColorScheme.fromSeed(seedColor: #7D858D)` (:9-10).
- Seed ne lacivert ne turuncu. Tek bir gri-mavi. Bu yüzden `Checkbox`, `Switch`, `ChoiceChip`, `DatePicker`, `TimePicker` ve input odak çizgisi gibi **elle stillendirilmemiş** Material bileşenleri bu griden türeyen tonlara düşer.
- Sadece 4 override var: scaffold beyaz (:11), AppBar beyaz/elevation 0 (:12-15), snackbar floating (:16-18), progress indicator laciverti (#0F294A, :20-22).
- `textTheme`, `buttonTheme`, `inputDecorationTheme`, `cardTheme`, `dialogTheme`, `chipTheme` **yok**.

### 1.3 Gerçekte kullanılan marka lacivert ve turuncu aileleri

Logo dosyasından ölçülen gerçek marka renkleri (`assets/smaplogo.png` piksel sayımı):

- Turuncu **#F16D38**.
- Lacivert **#2D3A54**.
- Üst üste binme koyusu **#2B1912**.

Kodda bu üç değerin hiçbiri yok.

**Lacivert / koyu mavi (en az 12 farklı değer):**

| Hex | Adet | Örnek yer |
|---|---|---|
| #0F294A | token + 7 literal | `app_colors.dart:23`, `my_card_info_card.dart:116,143,169,416` |
| #162A40 | 23 | `interview_detail_screen.dart:140`, `omd_loading.dart:358`, `main_inapp_webview.dart:148`, `preview_widget.dart:39,189` |
| #0D2744 | 16 | `login_screen.dart:137`, `login_card.dart:227`, `home_students_cards.dart:200`, `register_form.dart:21`, `role_toggle_button.dart:15`, `interview_card.dart:16` |
| #1A3D66 | 2 | `app_user_avatar.dart:13`, `account_settings_navy_header.dart:69` |
| #1A365D | 6 | `onboarding_page.dart:117,195,223` |
| #1E344A | 3 | `analytics_view_provider.dart:309,416` (grafik çizgisi) |
| #3D526D | 2 | `my_test_result_detail_screen.dart:279` |
| #10284A | 3+ | `lesson_bar.dart:170`, `lesson_detail_page.dart:683`, SVG'ler (`subheading_card.svg`) |
| #1F2937 | 6 | `omd_loading.dart:871`, `edebiyat_lesson_detail_page.dart:137` |
| #1A237E (Indigo 900) | 11 | `my_card_lesson_grid_item.dart:113`, `my_card_lesson_detail_page.dart:199`, `omd_result_flow_view.dart` ×5 |
| #436C95 / #162A3F (α93%) | 2 | `home_lessons_cards.dart:234,246` ve `lesson_navigation_helper.dart:140,151` (TYT/AYT butonları) |
| #2B4C78 | 1 | `add_lessons_top_header.dart:228` (`Color.fromARGB(255,43,76,120)`) |

**Turuncu (en az 9 farklı değer):**

| Hex | Yer |
|---|---|
| #FF6600 | token + `my_card_info_card.dart:394,400,405,440`, `my_test_result_detail_screen.dart:280` |
| #FF6F00 | `omd_loading.dart:872`, `omd_result_flow_view.dart:189` |
| #FF6D00 | `my_card_summary_card.dart:41`, `analytics_view_provider.dart:326` |
| #FF8A00 | token `accentOrange`; `my_test_results_detail_widgets.dart:439,454` |
| #FF7A00 | token `navIndicator` |
| #F97316 | `lesson_detail_page.dart:413,444`, `edebiyat_lesson_detail_page.dart:593` |
| #F68A3F | `analytics_view_provider.dart:322` (grafik serisi) |
| `Colors.orange` (29 kullanım) | `net_chart_card.dart:250`, `preview_widget.dart:58..`, `my_test_results_card.dart` yıldız |
| #FF6400 | SVG'lerin içine gömülü (`assets/svgs/correct.svg`, `home.svg`, …) |

Eski SMAP üçgen logosunun rengi de aynı #FF6400. `logoSmap.png` pikseli (255,100,0) ve onboarding ekran görüntülerinde görünüyor. Kod #FF6600'e, yeni logo #F16D38'e gidiyor, yani marka turuncusu üç kez farklı.

### 1.4 En çok kullanılan 25 hard-coded `Color(0x…)` (toplam 424 literal, 153 farklı)

| # | Hex | Adet | Rol | Başlıca yerler |
|---|---|---|---|---|
| 1 | #162A40 | 23 | koyu lacivert | `interview_detail_screen.dart` (9), `omd_loading.dart` (8), `camera_tutorial.dart` (2), `preview_widget.dart` (2) |
| 2 | #64748B | 20 | slate-500 ikincil metin | `my_test_results_detail_widgets.dart` (7), `account_settings_screen.dart` (2), `lesson_detail_page.dart` (2), `add_lessons_top_header.dart:258` |
| 3 | #E8ECF0 | 18 | input/kart kenarı | `account_settings_screen.dart` (4), `account_settings_text_field.dart` (3), `schedule_list_search_field.dart:54` |
| 4 | #0D2744 | 16 | koyu lacivert (auth/koç) | `login_card.dart`, `home_students_cards.dart` (3), `student_card.dart` (2) |
| 5 | #E2E8F0 | 14 | slate-200 kenar | `my_test_results_detail_widgets.dart` (4), `home_lessons_cards.dart:426` |
| 6 | #F3F4F6 | 14 | gri-100 zemin | `edebiyat_lesson_detail_page.dart` (4), `my_test_result_detail_screen.dart:75,283`, `invoice_table_header.dart:12` |
| 7 | #EF4444 | 13 | hata/yanlış | `edebiyat_lesson_detail_page.dart` (4), `lesson_detail_page.dart:254,278`, `lesson_bar.dart:261` |
| 8 | #1E293B | 12 | slate-800 başlık | `my_test_results_detail_widgets.dart` (7), `account_settings_screen.dart:165` |
| 9 | #1A237E | 11 | indigo | bkz. 1.3 |
| 10 | #F1F5F9 | 9 | segment tepsisi | `general_filter_panel.dart` (3), `lesson_detail_page.dart` (2), `add_topic_popup.dart:127` |
| 11 | #0F294A | 7 | lacivert | `my_card_info_card.dart` (5) |
| 12 | #22C55E | 7 | başarı | `contract_card.dart:18`, `notification_toggle_tile.dart:18`, `my_test_result_detail_screen.dart:281`, `edebiyat_lesson_detail_page.dart` (4) |
| 13 | #FF6D00 | 7 | turuncu | `omd_result_flow_view.dart` (4) |
| 14 | #FF6600 | 6 | turuncu | `my_card_info_card.dart` (4) |
| 15 | #94A3B8 | 6 | slate-400 | `my_test_results_detail_widgets.dart` (4), `general_filter_panel.dart` (2) |
| 16 | #1F2937 | 6 | gri-800 | bkz. 1.3 |
| 17 | #1A365D | 6 | lacivert | `onboarding_page.dart` (3, ve ölü kopya) |
| 18 | #F5F5F5 | 5 | açık gri | `my_cards_detail_page.dart` (2), `question_detail_page.dart` (2) |
| 19 | #E8F1FA | 5 | auth input dolgusu (mavi tonlu) | `login_card.dart:228`, `register_form.dart:22`, `forgot_password_screen.dart:9` |
| 20 | #FFFFFF | 4 | beyaz literal | `edebiyat_lesson_detail_page.dart` (2) |
| 21 | #FF8A00 | 4 | turuncu | `my_test_results_detail_widgets.dart` (3) |
| 22 | #FEE2E2 | 4 | hata zemini | `lesson_bar.dart:253`, `edebiyat_lesson_detail_page.dart` (2) |
| 23 | #F9FAFB | 4 | menü satırı zemini | `account_menu_tile.dart:28` |
| 24 | #F97316 | 4 | turuncu | bkz. 1.3 |
| 25 | #F8F9FA | 4 | zemin | `my_cards_detail_page.dart`, `my_card_page.dart` |

Aynı sayıda (4 adet) olan diğer değerler: #F0F4F8 (`login_screen.dart:138`), #F0F0F0, #E9ECF2, #10B981, #0F172A.

Not: #E8F1FA, #0D2744 ve #1A365D sayıları ölü kopya dosyalardan (`lib/views/auth/login_view.dart`, `lib/views/onboarding/onboarding_page.dart`) şişiyor. Bkz. 8.9.

**Diğer renk biçimleri:**

- `Colors.*`: `white` 224, `grey`/`grey.shadeN` 158, `black` 89, `transparent` 59, `red` 42, `orange` 29, `green` 24, `redAccent` 17, `blue` 6, `amber` 6.
- `Color.fromARGB`: 9 kullanım. `my_card_info_card.dart:282,362`, `question_detail_page.dart:784,794,827,860`, `net_chart_card.dart:153`.
- Opaklık: `withOpacity` 75, `withValues` 15 (iki API karışık).

**Nötr renk aileleri (en az 5 ayrı sistem):**

- Tailwind slate: #64748B, #94A3B8, #E2E8F0, #F1F5F9, #1E293B, #0F172A, #F8FAFC.
- Tailwind gray: #9CA3AF, #F3F4F6, #F9FAFB, #1F2937, #374151, #E5E7EB.
- Material `Colors.grey.*` (158 kullanım).
- `AppColors` özel nötrleri: #1C1F33, #8A90A6, #B2BAC6, #F5F7F9.
- Tek seferlik tonlar: #E8ECF0, #E8EAED, #EAECEF, #E9ECF2, #E9EDF2, #F1F3F9, #EEF0F3, #E9ECEF, #68717D, #9AA1AA, #5F6875, #2B3A4A, #B4BAC3, #B8C0CC.

### 1.5 Ders renkleri (`lib/core/constants/lesson_constants.dart`)

Her ders için `lessonColor` (açık zemin) + `barColor` (koyu vurgu) hex string olarak tutuluyor ve `AppColors.hexToColor` ile parse ediliyor. Satır numaraları `allLessons` içindeki ilk ders girişini gösterir. TYT/AYT eşlenikleri aynı renkleri paylaşır.

| Ders | lessonColor | barColor | Satır (TYT) |
|---|---|---|---|
| Türkçe | #f7ede4 | #a67762 (kahve) | :115-116 |
| Tarih | #ffeed6 | #eaa353 (kehribar) | :130-131 |
| Coğrafya | #d7eefe | #3b97d3 (mavi) | :145-146 |
| Matematik | #fde7e8 | #fa4b56 (kırmızı) | :160-161 |
| Geometri | #cde0fe | #3b69b0 (indigo mavi) | :175-176 |
| Fizik | #dbf4ff | #0276a4 (petrol mavi) | :190-191 |
| Kimya | #ffe5eb | #db5669 (gül) | :205-206 |
| Biyoloji | #d5f1cb | #12a335 (yeşil) | :220-221 |
| Edebiyat (AYT) | #f7f5e8 | #d56c70 (gül/mercan) | :237-238 |

Gözlemler:

- Matematik (#fa4b56), Kimya (#db5669) ve Edebiyat (#d56c70) üç yakın kırmızı-pembe. Çocuk gözüyle ayırt etmek zor.
- Tarih'in kehribarı (#eaa353) marka turuncusuna yakın, kafa karıştırabilir.
- Üçüncü bir ders renk sistemi daha var: `assets/icons/icon1-8.png` (38×38 renkli rozetler) Tailwind-500 tonlarında, pembe #E4528F, sarı #EDDD55, amber #F59E0B, kırmızı #EF4444, mor #8B5CF6, yeşil #10B981, mavi #3B82F6, cyan #06B6D4. Programlama ekranında `mapImage` ile kullanılıyor (`add_lessons_page.dart:234`).
- `icon3.png` (amber) Coğrafya, Matematik ve Geometri'ye atanmış (`lesson_constants.dart:144,159,174,266,296,311,326`). Veri hatası olabilir.
- Dördüncü sistem: `analytics_view_provider.dart:319-329` 8 renklik "dağılım grafiği" serisi. #3E516A, #F68A3F, #1D3B5E, #F7B889, #98A4B2, #FF6D00, #B0B7C0, #4A90E2. `index % 8` ile tekrar eder, ders renginden bağımsızdır.

### 1.6 Başarı / hata / nötr (D / Y / B)

D/Y/B için **dört ayrı renk sözlüğü** var. Aynı "Doğru/Yanlış/Boş" üçlüsü ekrandan ekrana farklı renkte:

| Yer | Doğru | Yanlış | Boş |
|---|---|---|---|
| `my_test_results_detail_widgets.dart:353-354, 386-388` | #4CAF50 | #F44336 | `Colors.black` |
| `omd_result_flow_view.dart:192-193, 1095-1097` | #4CAF50 | #F44336 | `Colors.black` |
| `my_test_results_detail_widgets.dart:624-630, 1016-1027` (ders akordeonu) | #10B981 | #EF4444 | #94A3B8 |
| `my_test_result_detail_screen.dart:281-282, 325-333` | **kDarkBlue #3D526D** (yeşil değil) | #EF4444 | (yok) |
| `omd_result_flow_view.dart:1305-1317` | "Net" `Colors.green`, "Doğru" `Colors.grey` | `Colors.red` | (yok) |
| `analytics_view_provider.dart:283-300` (özet kartları) | SVG ikonları `rank/correct/wrong/pass.svg`, kendi içlerinde #FF6400 turuncu | | |
| `my_card_lesson_grid_item.dart:81-95` | "Doğru" lacivert, "Eksik" turuncu, "Favori" `Colors.orange` | | |

Üç ayrı yeşil/kırmızı ailesi: Material (#4CAF50/#F44336), Tailwind (#22C55E/#10B981/#EF4444) ve iOS sistemi (#34C759/#FF383C, `assets/icons/information_card_green/red.svg`). Bunlara bir de `Colors.green/red/redAccent` (SnackBar'larda 8 yeşil, 4 kırmızı, 2 redAccent, 1 turuncu) ve `home_menu_grid.dart:274` #E53935 (rozet) ekleniyor.

Boş = nötr olarak ya siyah (`Colors.black`) ya da slate-400 kullanılmış. Bilgi kartı SVG'lerinde "eksik/hata" kırmızısı #FF383C.

---

## 2. Tipografi

- **Font ailesi tanımlı değil.** `pubspec.yaml` içinde `fonts:` bölümü yok (`flutter:` altında yalnızca `uses-material-design: true`, :95, ve `assets:`, :97). `google_fonts` paketi yok. Kodda `fontFamily`, `GoogleFonts`, `textTheme`, `TextTheme` araması 0 sonuç verdi. Sonuç: Android'de Roboto, iOS'ta SF Pro.
- Marka görsellerinde başka bir yüz var. `assets/logotext.png` wordmark'ı ("Student" ince lacivert / "map" kalın turuncu) Montserrat benzeri geometrik sans gibi görünüyor (görsel tahmin). `ob1-6.png` onboarding ekran görüntülerinde de Poppins benzeri geometrik bir font var. Bu ekran görüntüleri eski bir sürümden, güncel kod ise sistem fontu kullanıyor.
- **Türkçe glif desteği:** Roboto ve SF Türkçe karakterleri (ı İ ş Ş ğ Ğ ç Ö ü) destekler. `main.dart:93-94` locale `tr_TR`, `initializeDateFormatting('tr_TR')` var (:33). Ancak diakritiksiz yazılmış kullanıcıya görünen metinler var: `lesson_distribution_chart_card.dart:50` "Eksik Ders Konu **Dagilimlari**", `analytics_view_provider.dart:434,439` "Ort. **Siralama**", "Toplam **Dogru**" (aynı özetin bir önceki dalında doğru yazılmış "Toplam Doğru" :283), `analytics_general_data.dart:63,68,74` ("Siralama", "Dogru", "TYT Turkce").
- **TextStyle sayısı:** 528 `TextStyle(` oluşumu. `Theme.of(context).textTheme` kullanımı **0**. Hepsi satır içi.
- **Farklı hard-coded `fontSize` değeri: 18** (toplam 417 kullanım): 9 (×9), 10 (×28), 10.5 (×4), 11 (×28), 12 (×57), 12.5, 13 (×55), **14 (×78)**, 15 (×30), 16 (×45+1), 17 (×6), **18 (×39)**, 20 (×13), 22 (×13), 24 (×4), 26 (×3), 28 (×2), 32 (×1).
- **Ağırlıklar:** `bold` 181, `w600` 86, `w700` 60, `w500` 52, `w800` 13, `w400` 5, `normal` 2. `bold` ve `w700` aynı şey, toplam 241 "kalın".
- **letterSpacing** neredeyse hiç yok: -0.5 (×3, onboarding başlığı `onboarding_page.dart:196`), -0.2 (×2, `home_person_card.dart:60`), 1.2 ve 1 (×1'er). **height** (satır aralığı) yaklaşık 40 yerde: 1.4 (×12), 1.2 (×9), 1.5 (×7) ve diğerleri.
- **Duyarlı yazı boyutu** iki yerde elle yapılmış: `lesson_distribution_chart_card.dart:19-24` (`screenWidth * 0.028…0.046` + `clamp`), `stats_grid.dart:41` (`scale = (cardWidth/160).clamp(0.85,1.2)`). Metin ölçeklemesi (`textScaler`) için hiçbir sınır konmamış.

Gerçekte oluşmuş rol haritası:

| Rol | Stil | Yer |
|---|---|---|
| Üst bar başlığı | 18 / w700 / beyaz | `custom_top_app_bar.dart:64-68` |
| Üst bar kullanıcı adı / rol | 13 w600 beyaz / 11 w500 turuncu | `header_user_section.dart:77-90` |
| Onboarding başlığı | 26 / bold / -0.5 / #1A365D | `onboarding_page.dart:192-197` |
| Onboarding açıklama | 15 / gri / h1.5 | `onboarding_page.dart:203-207` |
| Dialog başlığı | 20 / bold / turuncu | `app_dialog.dart:53-57` |
| Kart başlığı (grafik) | 14 / w700 (net chart), 16-18 duyarlı (dağılım) | `net_chart_card.dart:150`, `lesson_distribution_chart_card.dart:51` |
| Gövde | 14 / 13 / 12 | genel |
| Menü kutucuk etiketi | 12 / w700 / h1.2 | `home_menu_grid.dart:284-289` |
| Ders kartı etiketi | 10 / w600 / h1.15 | `home_lessons_cards.dart:403-408` |
| İlerleme alt metni, uyarı rozeti | **9** / w500-w600 | `lesson_bar.dart` (konu tamamlandı, "N Eksiğin var") |
| Stat kartı değeri | 20×scale / w700 / #2B3A4A | `stats_grid.dart:97-100` |
| Nav etiketi | 12 / seçili w700, pasif w500 | `custom_bottom_nav_bar.dart:216-220` |

---

## 3. Boşluk, yarıçap, gölge, gradyan, blur

### 3.1 Boşluk

- `SizedBox(height)`: 8 (×43), 16 (×34), 12 (×32), 6 (×29), 20 (×29), 24 (×21), 4 (×20), 10 (×16), 15 (×12), 14 (×11) ve 2, 3, 5, 25, 28, 30, 32, 36, 40 (19 farklı değer). 3, 5, 14, 15, 25 gibi ızgaraya oturmayan değerler var.
- Yatay padding: 16 (×40), 20 (×18), 4/8/12 (~×11 her biri), 24 (×7), 30, 40, 56.
- Sayfa kenar boşluğu birleşik değil: Anasayfa 16 (`home_screen.dart:58`), Analiz 20 (`analytics_screen.dart:59`), Derslerim kart detay 24 (`my_cards_detail_page.dart:~335`), Onboarding butonları 40 (`onboarding_page.dart:99`), segment sol/sağ 24 (`my_card_header.dart:111-112`).
- Izgaralar: menü 3 sütun, boşluk 12, `childAspectRatio 0.9` (`home_menu_grid.dart:99-102`). Stat grid 2 sütun, boşluk 10, oran 1.58 (`stats_grid.dart:19-22`).
- `Border` kalınlıkları: 1 (×8), 1.5 (×6), 2 (×5), 3 (×2).

### 3.2 Köşe yarıçapı

`BorderRadius.circular` toplam **364**, **22 farklı değer**:

- 12 (×115), 16 (×55), 8 (×47), 10 (×44), 20 (×18), 6 (×17), 24 (×13), 4 (×8), 14 (×8), 15 (×7), 30 (×6), 5 (×3), 2 (×3), 99/100/999 (×8, hap), ve 0, 3, 7, 9, 18, 28 tek tek.
- Doğrudan `Radius.circular` (BorderRadius.only içinde): 32 (×16, başlık alt köşeleri), 24 (×9), 4/8/18/20 (×4'er), 22 (×4).
- `RoundedRectangleBorder` 90 yerde. `StadiumBorder` ve `RoundedSuperellipseBorder` hiç yok. `BoxShape.circle` 32, `CircleAvatar` 16.
- Başlık bandı alt yarıçapı **32** yedi ayrı yerde elle kopyalanmış: `custom_top_app_bar.dart:21`, `home_navy_header_band.dart:17`, `day_selection_top_app_bar.dart:17`, `add_lessons_top_header.dart:62`, `account_settings_navy_header.dart:40`, `my_card_lesson_detail_header.dart:33`, `question_detail_page.dart:160`.

Tipik bileşen yarıçapları:

| Bileşen | Yarıçap | Yer |
|---|---|---|
| Menü kutucuğu | 16 | `home_menu_grid.dart:247,251` |
| Ders kartı (Anasayfa) | **9**, InkWell 16 | `home_lessons_cards.dart:377` vs :371 |
| Stat kartı | dış 12, iç beyaz **6** | `stats_grid.dart:53` vs :66 |
| Grafik kartları | 8 | `net_chart_card.dart:135`, `lesson_distribution_chart_card.dart:35` |
| Filtre paneli | 20 | `general_filter_panel.dart:108` |
| Kişi kartı | 12 | `home_person_card.dart:36` |
| Takvim kartı | 16 (iç ve dış) | `home_month_calendar.dart:86,90,116` |
| Bilgi kartı (swiper) | 24 | `my_card_info_card.dart:233` |
| Login kartı | 16 | `login_card.dart:113` |
| Login butonu | **15** | `login_card.dart:381` |
| Inputlar | 12 (auth, arama) ve **8** (hesap ayarları) | `login_card.dart:~262`, `account_settings_text_field.dart:44` |
| Dialog | 12 (ders seçimi) ve 20 (duyuru, bilgi kartı) | `home_lessons_cards.dart:153`, `app_dialog.dart:29` |
| Bottom sheet | üst 24 (ölü kod) ve üst 20 | `home_lessons_cards.dart:180`, `omd_loading.dart:389,604` |
| Segment tepsi / chip | 12 / 10 | `my_card_header.dart:118,168` |
| Analiz üst sekme chip'i | **7** | `analytics_tabs.dart:33,43` |
| Nav barı | üst 20 | `custom_bottom_nav_bar.dart:30-33` |
| Kamera FAB | 20 (74×74 yuvarlatılmış kare) | `custom_bottom_nav_bar.dart:240-244` |

### 3.3 Gölge ve yükseltme

- `BoxShadow` 57 adet. `blurRadius`: 4 (×14), 8 (×11), 10 (×11), 6 (×9), 20 (×5), 12 (×3), 5 (×2), 15. Offset hep sadece Y: (0,2) ×23, (0,4) ×11, (0,3) ×6, (0,1) ×4, (0,8) ×3, (0,10) ×2, ayrıca (0,5), (0,6). `spreadRadius` 4 yerde (1, 2, 2, 3, 5).
- Gölge renkleri: `AppColors.shadowLight` (×13), `shadowMedium` (×5), ama bir de `Colors.black.withOpacity(...)` ile 0.03, 0.04, 0.05, 0.08, 0.10, 0.12 gibi **6 ayrı alfa**. `Colors.black12` (×3), `Colors.grey.withOpacity(0.2)`. Lacivert tonlu: #0F172A α8% ve α5% (`general_filter_panel.dart:117-128`).
- En ağır: filtre paneli çift gölge, ilki `blur 20, offset (0,22), spread 5` (`general_filter_panel.dart:117-123`). Login kartı `blur 20, offset (0,10), α12%` (`login_card.dart:115-119`).
- Alt navigasyon gölgesi `offset (0,8), blur 20` (`custom_bottom_nav_bar.dart:35-39`). Çubuk ekranın altında olduğu için pozitif Y offset gölgeyi çubuğun altına, yani görünür alanın dışına iter. Çubuğun üst kenarında yükselti hissi için negatif Y gerekirdi.
- Material `elevation`: 0 (×31, düz butonlar), 24 (×2, varsayılan dialog), 6, 4, 2 (×3), 1.

### 3.4 Gradyan

Toplam **4 `LinearGradient`**, hepsi aynı ilerleme çubuğu dolgusunun kopyası: `lesson_bar.dart:200`, `lesson_detail_page.dart:713`, `edebiyat_lesson_detail_page.dart:909`, `subject_detail_page.dart:454`.

- Açı: soldan sağa (`centerLeft → centerRight`, yani 0°).
- Renkler: `[barColor, barColor α45%]`, `stops [0.1, 1.0]`.
- Ray `unselectedGrey` #E2E8F0, yükseklik 8, dış `ClipRRect` 99, iç dolgu sadece sağ köşeleri 24.

Başka gradyan, `RadialGradient`, `SweepGradient`, `ShaderMask` yok.

### 3.5 Blur

- `BackdropFilter` 2 yerde, 1 `ImageFilter.blur`'lü maske: `general_filter_panel.dart:478` (sigma 8×animasyon; **bu fonksiyon `showBlurredFilterDialog` hiç çağrılmıyor**, ölü), `preview_top_info_widget.dart:15` (kamera üst bilgi bandı, sigma 5, `grey.shade100` α50%), `preview_widget.dart:159` (kamera kırpma maskesi `ImageFilter.blur()` varsayılan).
- Dashed çerçeve boyayıcı (`_DashedBorderPainter`): `general_filter_panel.dart:436`. Onboarding ekranındaki kesikli "seçili ders" çerçevesi bununla eşleşiyor.
- Balon kuyruğu boyayıcı: `edebiyat_lesson_detail_page.dart:2430` (yazar sözü balonu).

---

## 4. İkon ve illüstrasyon

### 4.1 Paketler

- `uses-material-design: true` (`pubspec.yaml:95`). Material Icons **208 kullanım**: `_rounded` 114, düz/filled 85, `_outlined` 9. Aynı eylem için farklı varyant: geri oku `Icons.arrow_back_ios` (×14), `arrow_back_ios_new_rounded` (×6, üst bar `header_user_section.dart:39`), `arrow_back` (×3), `arrow_back_ios_new` (`omd_loading.dart:~254`).
- `cupertino_icons: ^1.0.6` (`pubspec.yaml:36`) **tanımlı ama 0 kullanım**. `CupertinoIcons.*` hiç yok.
- `flutter_svg ^2.0.9` (:60): 66 SVG dosyası, çoğunlukla `ColorFilter.mode(color, srcIn)` ile tek renge boyanıyor.
- İkon boyutları: 20 (×33), 22 (×15), 18 (×14), 14 (×10), 28 (×11), 16 (×8), 12 (×5), 13, 24, 26, 30, 32, 36, 40, 48, 50, 72, 80, 100: 21 farklı boyut.
- `flutter_html` (:64) sözleşme ve kayıt metinleri için (`register_form.dart:227`, `contracts_screen.dart:70`).

### 4.2 Asset klasörleri (644 dosya, 67 MB)

Dosya türleri: 574 PNG, 66 SVG, 2 JPG, 2 ZIP. Boyut: `authors` 38 MB, `avatars` 10 MB, `menuIcons` 4,6 MB, kökteki `ob1-6.png` ~7,7 MB.

**Kök (assets/):**
8p, biological, cards.svg, chart.svg, cografya, contract_icon, edebiyat, fen, geometry1, home.svg, **ikonlar.zip** (106 KB), llg1, llg5-9, loginImage, logo, logoD, logoSmap, logob1-6, logod1-5, logos1-6, logosm1-5, logotext, logoy1-4, master.svg, mat, ob1-6, optic1-4, org1.jpg, physics, profile.svg, smaplogo, smpr1-2, tarih, turkce, visaa.svg.

- `smaplogo.png` (1080×1080, şeffaf): S monogramı. Lacivert + turuncu üst üste binmiş, kesişim koyu kahverengi. Üst barda 40×40 kutuda gösteriliyor (`header_user_section.dart:51-56`), ama tuvalin ~%40'ı boş kenar, çizim ~24 px'e iniyor. Navy zeminde logonun lacivert yarısı (#2D3A54, bar zemini #0F294A) kayboluyor.
- `logo*.png` serisi (logob, logod, logos, logosm, logoy, llg, smpr, 8p): aynı S monogramın ve en az üç alternatif markanın (yılan/yay şekli, turuncu S kurdelesi, lacivert "SM" kare, harita deseni kare) denemeleri. 40'a yakın logo varyantı var. `logotext.png` (785×774) launcher ikonu kaynağı (`pubspec.yaml:81`), yani uygulama ikonunun içinde küçük "Student map" yazısı var.
- `loginImage.png` (323×300): lacivert katlanmış harita + iki kaşif figürü, turuncu hat çizgileri. Düz vektör illüstrasyon, düz tonlu (`login_card.dart:253`).
- `ob1-6.png` (1419×2796): eski sürüm arayüzünün telefon çerçeveli ekran görüntüleri (hamburger menü, turuncu hap sekmeler, eski üçgen logo). Onboarding'de kullanılıyor (`onboarding_page.dart:22-44`). Her biri 0,9-2,3 MB.
- `optic1-4.png`, `org1.jpg`: fotoğraf. Optik form tarama ekran görüntüleri (ahşap masa üstü fotoğraf, turuncu köşe noktaları). `org1.jpg` (1800×600) optik form şeridi.
- `turkce/mat/fen/tarih/cografya/edebiyat.png` (512×512): düz ders illüstrasyonları (4. ders ikon seti), çoğu `my_card_dummy_data`/dummy sonuç listelerinde.
- SVG'ler: `cards.svg` (#637381), `chart.svg`/`profile.svg` (#919EAB) nav ikonları, `home.svg` (#FF6400). `master.svg` ve `visaa.svg` kart markaları.

**assets/icons (31 dosya):**
- Ders illüstrasyonları (512×512, **düz 2B çok renkli**): `open-book` (Türkçe), `historybook2` (Tarih), `cografya`, `poetry` (Edebiyat), `sine` (Matematik), `geometry1`, `physics`, `chemistry3`, `biological`. Anasayfa ve Derslerim kartlarında **28×28** gösteriliyor (`home_lessons_cards.dart:386-388`, `my_card_lesson_grid_item.dart:45-47`). Bu detay seviyesi 28 px'te okunmuyor.
- `icon1-8.png` (38×38): renkli yuvarlatılmış kare rozet + beyaz çizgi glif (bkz. 1.5).
- `subjecticon.png` (67×80): gri çizgi kitap, varsayılan konu ikonu (`lesson_bar.dart:106,124`).
- `calendar.png`.
- SVG: `bag`, `camera`, `information_card{,_gray,_green,_red,_with_border_green,_with_border_red}`, `lesson2`, `lessons`, `matter_card`, `subheading_card`.

**assets/svgs (48 dosya):**
- Aileler: (a) Iconsax stili duotone 24×24, #292D32, `opacity .4`: `bag`, `cards`, `logout`, `note`. (b) marka-turuncu #FF6400 28×28: `correct`, `wrong`, `pass`, `point`, `rank`, `totalmexam` ve 24×24 `ntf`, `unlock`, `personalcard`. (c) 16×16 #4A5A6A ders glifleri: `chemistry`, `geography`, `geometry`, `history`, `language`, `math`, `physics`, `general`. (d) #141B34: `microscope`, `plant`, `plant2`. (e) **potrace ile bitmap'ten vektörleştirilmiş** 512pt siyah dolgu: `book1-8`, `analysis`, `calendar1-4`, `pen1-6` (XML başlığında `DOCTYPE svg 20010904`), `chart.svg` 23 KB, `deneme.svg` 33 KB. (f) `bookr`, `bookr2`, `bookr212`.
- Görselde 24×24 çizgi (Iconsax) + 16×16 dolgu glif + 28×28 turuncu dolgu + siyah trace karışımı var. Stil tutarlı değil.

**assets/menuIcons (139 dosya, ~4,6 MB):**
- Adlar: a0, a1, a2, a14, analysis, blog, br, br1, br2, business, button, buzzer, calendar, cards, cup, customer-survey, da, da2-4, dashboard, data-analytics, donut-chart, exam, exam1, examination, exams, exploratory-analysis, game-show, graph, insight, iw1-30, league, letter (1-4), letter, letter2, letters, m1-15, mail, mail (1), market-analysis (+(1)), messages, metrics, mf1, mf2, note, online, online1, person, physics (5), predictive-analytics, quiz, quiz (1), quiz-game, quiz2-4, rating, research, reward, select, seo, skill, smapc, student, student1-4, 6-12, 14-17, 20-23, students1-4, students2.zip, test, traffic, unboxing.
- Stil: **tek bir set değil, stok illüstrasyon pazar yeri karışımı.** `a0.png` (312×312): lacivert kalın dış çizgili, renk dolgulu çizgi illüstrasyon. `exams.png` (1024×1024): yumuşak gradyanlı düz illüstrasyon (kalem tutan el). `iw*`, `student*`: insan figürlü düz illüstrasyonlar. `reward.png`, `cup.png`, `league.png`: parlak 3B-vari madalya/kupa/elmas. `smapc.png` (49×48): puan madeni parası.
- `exams.png` RGB katmanında sahte dama deseni var (piksel alfa=0, ama RGB (209,209,209)/(254,254,254)), yani şeffaf, ama arka planı AI/ekran görüntüsünden silinmiş bir kaynak.
- Anasayfa menüsü bunlardan 6 öğrenci + 6 koç ikonu seçiyor (`home_menu_grid.dart:13-81`).

**assets/avatars (23 dosya, 10 MB):** `1avatar`, `1avatarN`, `1avatarN3`, `3avatarN`, `3avatarN3`, `4avatarN`, `4avatarN3`, `5avatar`, `5avatarN`, `5avatarN3`, `6avatarN`, `6avatarN3`, `7avatar`, `8avatar`, `8avatarN3`, `9avatar`, `9avatarN`, `9avatarN3`, `Jonas`, `Mark`, `avatar4`, `avatar5`, `user`.
- Stil: **Pixar benzeri 3B karikatür kafa**, düz renkli daire zeminde (kırmızı #E5262D yoğun, turuncu, açık mavi, pembe, nane). Ana set `*N3.png` (259×256). `N` ve `N3` kopya çiftleri. `user.png` bunlardan tamamen farklı: siyah çizgi soru işareti dairesi (512×512, `authors/author.png` aynı).
- Diğer şemadan gelen ikisi (`Jonas`, `Mark`) ve `avatar4/5` farklı yüz/arka plan.

**assets/authors (≈331 dosya, 38 MB):** üst düzey `ahmethamditanpınar`, `author`, `kemaltahir`, `peyamisafa`, `resatnuri`, `sabahattinali`, `yasarkemal` (.png). Alt klasörler: `a` (15), `cb` (6), `cd` (7), `cde` (11), `cdmy` (8), `cds` (109), `cke` (5), `cm` (11), `cpm` (5), `ct` (10), `ctg` (10), `dn` (12), `ds` (42), `f` (5), `m` (27), `s` (13), `t` (13), `t1` (10), `t2` (5). Örnek: `a/asikomer.png`, `cds/ZiyaosmanSaba.png`, `cpm/orhanpamuk.png`, `dn/evliyacelebi.png`.
- Stil: **tarihî siyah-beyaz/sepya vesikalık fotoğraflar** (Edebiyat yazar profilleri). Boyut ve kırpma tutarsız, kimi yuvarlak kimi dikdörtgen.
- Not: `cpm` klasörü `pubspec.yaml`'daki `assets/authors/...` listesinde **yok** (`:112-113` `cm` ve `ct` var, `cpm` yok), bu 5 yazar görseli pakete girmiyor.

**Diğer:** `assets/splash/` (`android_12_splash.png`, `splash_logo.png` 1200×1200 şeffaf logo), `assets/tutorial/optic1.png` (klasör pubspec'te tanımlı değil). Android splash arka planı beyaz (`launch_background.xml`).

### 4.3 Asset yükleme modeli

Asset yolları sunucu verisinden geliyor: `'assets${lesson.image}'` (`home_lessons_cards.dart:389`), `'assets$authorImage'` (`edebiyat_lesson_detail_page.dart:1866`), `'assets/avatars/${user.photo}'` (`app_user_avatar.dart:35`), `'assets/icons/${task['mapImage']}'` (`add_lessons_page.dart:234`). Bu yüzden "kodda adıyla geçmeyen" asset (543 dosya) otomatik olarak ölü sayılmaz. Kapak/sınav görselleri ise ağdan (`Image.network` ×9, ör. `my_test_results_card.dart:28-72`, `https://smaptr.com.tr/uploads/...`).

---

## 5. Bileşen kalıpları

### 5.1 Üst bar / başlık

- **`CustomTopAppBar`** (`R/widgets/custom_top_app_bar.dart:27-77`): #0F294A zemin, 16/6 padding, 50 yükseklik, isteğe bağlı alt yarıçap 32 (varsayılan kapalı, `root_screen.dart:93-103` yorum içinde), isteğe bağlı 2 px turuncu alt çizgi (varsayılan kapalı). Sol: 40 px logo ya da geri oku (22 px beyaz). Sağ: ad (13/w600 beyaz) + rol (11/w500 turuncu) + `AppUserAvatar` r16 beyaz 2 px halka (`header_user_section.dart:33-98`).
- Derslerim sekmesinde bu bar gizleniyor (`root_screen.dart:87`) ve `MyCardHeader` aynı başlığı **yeniden yazıyor** (`my_card_header.dart:39-105`): lacivert bant, alt yarısı segment tepsisinin altında kalacak şekilde 24 px taşma (`_tabOverlap`, :20).
- **Lacivert bant motifi:** `NavyHeaderBand` (`shared/.../navy_header_band.dart:17-31`), `HomeNavyHeaderBand` (alt yarıçap 32, yükseklik `rowHeight/2`, `home_navy_header_band.dart:12-17`). `HomeLessonsCards` bandı üstte 60 px çiziyor, kartlar bandın üstüne biniyor (`home_lessons_cards.dart:40-46`). Yorum "ölçüler birebir aynı" diyor ama sabit 120 iken `HomeLessonsCards.rowHeight` varsayılanı 110 (`:16`).
- Material `AppBar` kullanan diğer ekranlar: `coach_programs_screen.dart:23` (lacivert, toolbarHeight 70), `interview_detail_screen.dart:528` (lacivert, 70, başlık 18/w700), `omd_loading.dart:250` (#162A40 + `arrow_back_ios_new`), `omd_loading.dart:978` (#1F2937, `centerTitle`, logo), **`coach_analytics_screen.dart:26` (renk verilmemiş, temadan beyaz AppBar)**.

### 5.2 Kartlar

- **Anasayfa ders kartı** (`home_lessons_cards.dart:361-448`): 90 px genişlik, beyaz, 1 px `grey.shade200` kenar, yarıçap 9, 28 px illüstrasyon + 10/w600 etiket. Sağ-alt köşede 24 px daire sayaç (turuncu 10/bold rakam, `:415-444`). İskelet: sabit `Opacity 0.6` + `LinearProgressIndicator` (shimmer yok, `:451-488`).
- **Menü kutucuğu** (`home_menu_grid.dart:247-297`): beyaz, `grey.shade200` kenar 1, yarıçap 16, 52×52 PNG. `_MenuItemData.iconBg` 12 öğenin hepsinde tanımlı (:17-81, #E3F2FD, #E0F2F1, #EDE7F6 …) ama `_IconCircle` (:300-317) hiç kullanmıyor, pastel daire fiilen yok.
- **Kişi/ilerleme kartı** (`home_person_card.dart:32-131`): lacivert, yarıçap 12, avatar + ad (15/w600/-0.2) + puan hapı (`0x22FFFFFF` zemin, 8 yarıçap, `smapc.png` 22 px) + 8 px ilerleme çubuğu (beyaz ray, turuncu dolgu, yarıçap 999) + yüzde (`0xCCFFFFFF` 12).
- **Stat kartı** (`stats_grid.dart:43-143`): imza motif. Turuncu #FF6600 bir kart arkada (üstten 3 px aşağı, yarıçap 12), üstte beyaz kart (yarıçap 6, 1 px #E8EAED kenar, gölge) ve alt kenarda 3 px turuncu "kalıntı" şerit. 32×32 #FFF1E4 ikon kutusu (yarıçap 8), değer 20/w700. İç yarıçap (6) dış yarıçapla (12) uyumsuz.
- **Grafik kartları:** beyaz, yarıçap 8, #E8EAED kenar, `shadowLight` (blur 10, 0/2) (`net_chart_card.dart:131-144`, `lesson_distribution_chart_card.dart:30-44`).
- **Test sonucu kartı** (`my_test_results_card.dart:32-163`): `menuCardBackground` zemin, yarıçap 12, kapak görseli (ağdan), yıldız ikonu `Colors.orange` 20 px, "Detay" butonu 28 px, lacivert, yarıçap 8.
- **Bilgi kartı (swiper)** (`my_card_info_card.dart:231-440`): beyaz, yarıçap 24, #E5E5E5 1.5 px kenar, α3% gölge. Alt butonlar yarıçap 10, turuncu çerçeveli ve lacivert dolgulu.
- **Hesap menü satırı** (`account_menu_tile.dart:27-66`): #F9FAFB zemin, yarıçap 12, 20 px turuncu SVG, 16/w500 metin, 28 px chevron.
- **Takvim** (`home_month_calendar.dart`): `menuCardBackground` dış kart (yarıçap 16), içte beyaz tablo, ızgara çizgisi #EEF0F3, "bugün" 30 px daire, #FFD4B3 dolgu + 2 px turuncu halka (`:213-221`).

### 5.3 Butonlar

- `ElevatedButton` 83, `TextButton` 49, `FilledButton` 16, `OutlinedButton` 4, `IconButton` 55. Hepsi `styleFrom(...)` ile yerinde stillendirilmiş. `elevation: 0` 31 yerde. Tema düzeyinde buton stili yok.
- Birincil buton rengi **tutarsız**: Giriş butonu lacivert #0D2744 (`login_card.dart:376-383`, yükseklik 50, yarıçap 15, `elevation: 2`). Onboarding butonu soluk gri-mavi #E9ECF2 + lacivert metin (`onboarding_page.dart:104-127`, yükseklik 55, yarıçap 12). "Detay" butonu lacivert (28 px, yarıçap 8). Dialog butonu varsayılan `accentColor = Colors.indigo` (`app_dialog.dart:13`, yarıçap 10). TYT/AYT seçim butonları #436C95 / #162A3F / #88929D (`home_lessons_cards.dart:234-263`, yarıçap 12). Turuncu yalnızca kamera FAB'ında ve seçili sekmelerde.
- Buton yükseklikleri: 55, 50, 44 (`home_students_cards.dart:372`), 28, plus padding'e bağlı olanlar.

### 5.4 Sekme, segment, chip

Segment kontrolü (TYT/AYT, filtre, sınav türü) **en az 6 kez elle yazılmış**, her seferinde farklı renk ve yarıçapla:

| Yer | Tepsi | Seçili metin | Yarıçap (tepsi/chip) |
|---|---|---|---|
| `my_card_header.dart:117,167-185` | #F5F7F9 | #FF6600 | 12 / 10 |
| `lesson_detail_page.dart:~295-413` | #F1F5F9 + gölge | **#F97316** | 12 / 10 |
| `general_filter_panel.dart:131-136` | #F1F5F9 | (turuncu) | **14** / ? |
| `question_detail_page.dart:205-241` (gerçek `TabBar`) | beyaz α10% | **#FF8A00** (`accentOrange`) | 12 / 10 |
| `analytics_tabs.dart:20-69` (yatay kaydırmalı chip dizisi) | yok, `ListView` | beyaz metin turuncu dolgu #FF6600, pasif #E9ECEF + #68717D | **7**, yükseklik 32 |
| `role_toggle_button.dart` (giriş/kayıt) | #0D2744 | lacivert | ? |

Projede yalnızca **1 `TabBar`** (`question_detail_page.dart:205`), 2 `TabController`, `SegmentedButton` hiç yok. `ChoiceChip` 4 yerde (`interviews_screen.dart:870,904`, `omd_loading.dart:429,476`), `Chip` 1.

### 5.5 Inputlar

`InputDecoration` 27, `OutlineInputBorder` 39, `TextField` 17, `TextFormField` 15.

- Auth: dolgu **#E8F1FA** (mavi tonlu), kenarlık yok, yarıçap 12, padding 16/13 (`login_card.dart:~255-275`).
- Hesap ayarları: beyaz dolgu, 1 px #E8ECF0, yarıçap **8** (`account_settings_text_field.dart:37-48`), salt okunur ise `grey.shade100`.
- Programım arama: beyaz dolgu, yarıçap 12, kenar #E8ECF0, filtre aktifken #FFD4B3 1.5 px (`schedule_list_search_field.dart:36-62`).
- Switch: yeşil #22C55E ray, beyaz baş, pasif #E5E7EB (`notification_toggle_tile.dart:28-34`, bu proje için tek `Switch`). Checkbox yarıçap 4, `activeColor` #0D2744 (`login_card.dart:~345`).

### 5.6 Bottom sheet ve dialog

- **Bottom sheet** yalnızca 3 `showModalBottomSheet`: `home_lessons_cards.dart:176` (**ölü kod**: `_showBottomPanel`, `_showTypeSelection`, `_showMiddleDialog` hiç çağrılmıyor, `onTap` `LessonNavigationHelper.showTypeSelection`'a gidiyor, `:367`), `omd_loading.dart:385,601` (üst yarıçap 20). Yani aktif kullanıcı akışında bottom sheet neredeyse yok; çoğu seçim dialog ile yapılıyor.
- **Dialog**: `showDialog` 36, `AlertDialog` 21, `Dialog` 19. Ortak `AppDialogs.showUnderConstruction` (`app_dialog.dart:7-194`): beyaz, `surfaceTintColor: transparent`, yarıçap 20, 72 px ikon, başlık 20/bold/turuncu, gövde 14/w600 #334155, detay 13 #64748B, tam genişlik buton (yarıçap 10), "Kapat" TextButton gri. Ders seçim dialogu yarıçap **12**, başlık `bold`, ders adı çiftli buton (`lesson_navigation_helper.dart:81-86`).
- Filtre paneli blur dialog'u (`general_filter_panel.dart:467-495`) fade+scale (0.95→1, 250 ms, `easeOutCubic`) ile hazır ama **çağrılmıyor**. Panel şu an `Positioned` ile sekme altında açılıyor (`analytics_screen.dart:93-108`).

### 5.7 Alt navigasyon ve kamera FAB (`R/widgets/custom_bottom_nav_bar.dart`)

- Beyaz çubuk, üst köşeler 20 yarıçap, yükseklik 72 + alt güvenli alan, yatay padding 4 (:24-41).
- 5 eşit slot (Anasayfa, Analizlerim/Öğrencilerim, **Kamera**, Derslerim/Görüşmelerim, Hesap), kamera 3. slot ve sekme değil (:44-52).
- Üst çubuk gösterge: 60×4 turuncu (#FF7A00, `navIndicator`) çubuk, `AnimatedPositioned` 180 ms `easeOut`, slot ortasına kayar (:66-87). İkon/etiket rengi ise #FF6600, yani gösterge ile içerik farklı turuncu.
- `_NavItem` (:163-226): seçiliyken 36×28 yuvarlatılmış hap (`navSelectedBg` #FFD4B3, yarıçap 14, `AnimatedContainer` 180 ms), 20 px ikon (SVG ya da Material `Icon`), 12 px etiket (seçili w700, pasif w500), renk seçili #FF6600 / pasif #B2BAC6.
- İkonlar karışık: öğrenci tarafında 4 SVG (`home`, `chart`, `cards`, `profile`), koç tarafında **Material** `Icons.people_rounded` (:107) ve `Icons.chat` (:127, `_rounded` bile değil).
- **Kamera FAB** (:228-266): özel widget, `FloatingActionButton` değil. 74×74 yuvarlatılmış kare (yarıçap 20, daire değil), #FF6600 dolgu, `orangeShadow` blur 20 offset (0,8), `Transform.translate(0,-12)` ile çubuğun üstüne taşıyor, ortada 32 px beyaz `camera.svg`. Basınca rota `MaterialPageRoute` ile `OpticMarkDetectionView2` (`root_screen.dart:48-52`).
- Kod hatası, görseli etkiler: `root_screen.dart:135` rol karşılaştırması `'teacher'`, geri kalan her yer `'coach'` kullanıyor.

### 5.8 Grafikler

- **`fl_chart ^1.2.0` yalnızca 1 yerde:** `net_chart_card.dart:168-325`, tek `LineChart`.
  - Yükseklik 260. Eğri (`isCurved`, `curveSmoothness 0.35`), çizgi 2 px, uçlar yuvarlak, **nokta yok, alan dolgusu yok** (`dotData`/`belowBarData` kapalı).
  - Çizgi rengi #1E344A (`analytics_view_provider.dart:309`).
  - Izgara: sadece dikey çizgiler, #D0D5DD α15% (`0x26D0D5DD`), 1 px, yalnızca görünen etiket indekslerinde. Yatay çizgi yok. Kenarlık: üst #EAECEF, sol/sağ aynı silik çizgi, alt yok.
  - X ekseni: "12 Ara." formatında en fazla 6 etiket (`maxDisplayedLabels = 6`), etiketsiz noktalar yerine 1,5 px `Colors.orange` nokta (:246-252). Y ekseni: "NN Net", 48 px ayrılmış alan, etiket 11 px #9AA1AA.
  - Tooltip: çizgi renginin α85%'i zemin, beyaz 12/w600 "xx.x Net".
- Diğer "grafikler" elle çizilmiş: yatay çubuk dağılımı (`lesson_distribution_chart_card.dart:185-280`, çubuk yüksekliği 34-42 duyarlı, sağ köşeler 4, metin sığarsa içeride beyaz, sığmazsa dışarıda çubuk renginde), ders ilerleme çubukları (bkz. 3.4), halka (`my_test_results_detail_widgets.dart:1047`, `CircularProgressIndicator(value: successRate)`), kişi kartı çizgi ilerlemesi.
- `pie`, `bar`, `radar` `fl_chart` türleri hiç kullanılmamış. Ders renkleri grafiklerde (dağılım serisi) kullanılmıyor, 1.5'teki 8 renkli ayrı palet kullanılıyor. `LessonBar` ilerleme değeri yer tutucu (`lesson_bar.dart:17`, `_placeholderProgress = 0.75`).

### 5.9 Kart destesi (swiper)

`flutter_card_swiper` (`my_cards_detail_page.dart:297`, `question_detail_page.dart:344`) ve `appinio_swiper` (`omd_result_flow_view.dart:78`) iki ayrı paket. Konfig: `numberOfCardsDisplayed` 2 (tek kartsa 1), `backCardOffset (0,40)`, padding 24/24 (`my_cards_detail_page.dart:332-343`).

---

## 6. Tema ve koyu mod

- **Yalnızca açık tema.** `main.dart:85` sadece `theme: AppTheme.light`. `darkTheme`, `themeMode`, `Brightness.dark` aramaları 0 sonuç. `AppTheme` sınıfında yalnızca `light` getter var (`app_theme.dart:7`).
- iOS `Info.plist`'te `UIUserInterfaceStyle` yok. Android'de `values-night/` klasörü var ama bu Flutter şablonunun varsayılanı.
- Beyaz zemin ve literal renkler her yere dağıldığı için (`Colors.white` 224, `Colors.grey.*` 158, 424 hex literal) sonradan koyu mod eklemek kolay olmaz. Önce token'lara geçilmeli.
- Durum çubuğu: `SystemUiOverlayStyle.light` + şeffaf (`root_screen.dart:88-91`), lacivert üst barla uyumlu, ama Anasayfa dışı ekranlarda (beyaz AppBar'lı) kontrol edilmedi.

---

## 7. Hareket

Hiç `AnimationController`, `Hero`, `TweenAnimationBuilder` veya `PageRouteBuilder` yok. Tüm sayfa geçişleri varsayılan `MaterialPageRoute` (×32). Yalnızca **örtük animasyonlar**:

| Süre | Adet | Yer / kullanım |
|---|---|---|
| 200 ms | 13 | genel (çoğu örtük) |
| 300 ms | 9 | onboarding gösterge ve `nextPage` `easeInOut`, kart sönme |
| 180 ms | 5 | nav gösterge ve hap, analiz sekme chip'i |
| 100 ms | 4 | |
| 600 ms | 3 | |
| 250 ms | 3 | filtre dialog'u (ölü) |
| 400 / 500 / 150 | 2 / 1 / 1 | |
| 1500, 1600 ms | 1'er | yükleme ekranları (`omd_loading`) |

- Eğriler: `easeInOut` (×9), `easeOut` (×3), `decelerate` (×2), `easeOutCubic` (×1).
- Kullanılanlar: `AnimatedContainer` 14, `AnimatedSwitcher` 6, `AnimatedOpacity` 4, `AnimatedCrossFade` 2, `AnimatedPositioned` 1, `FadeTransition` 1, `ScaleTransition` 1.
- Dikkat çekenler: nav gösterge kayması (`custom_bottom_nav_bar.dart:71-73`), kartın favoriden çıkınca sönmesi (`my_cards_detail_page.dart:318-326`, `AnimatedOpacity` 300 ms `easeOut`), hesap ayarlarında şifre görünürlük ve bölüm açılımı `AnimatedSwitcher`/`AnimatedCrossFade` (`account_settings_screen.dart:818,1002,1056,1104`), kayıt formunda `AnimatedSwitcher` (`register_form.dart:490,555`), swiper'ın kendi sürükleme animasyonu.
- Eksik: iskelet için shimmer yok (sabit `Opacity 0.6`), Lottie/Rive paketi yok, kamera tarama sırasında özel animasyon yok.

---

## 8. Tutarsızlık listesi

1. **Marka turuncusu üç farklı ve kod içinde en az 9 kopya.** Logo #F16D38, token #FF6600 (`app_colors.dart:6`), SVG'ler #FF6400, ayrıca #FF6F00 (`omd_loading.dart:872`, `omd_result_flow_view.dart:189`), #FF6D00 (`my_card_summary_card.dart:41`), #FF8A00 (`app_colors.dart:25`), #FF7A00 (`:22`), #F97316 (`lesson_detail_page.dart:413`), #F68A3F (`analytics_view_provider.dart:322`), `Colors.orange` (29 yer).
2. **Marka laciverti logoda #2D3A54, kodda en az 12 farklı lacivert** (bkz. 1.3). Aynı "başlık laciverti" #0F294A (resmî), #162A40 (kamera/görüşme), #0D2744 (auth/koç) olarak üç ayrı yerde.
3. **Segment kontrolü 6 kez yeniden yazılmış**, 4 ayrı seçili-turuncu (#FF6600, #F97316, #FF8A00, #FF6600+beyaz metin) ve 3 farklı tepsi rengi (bkz. 5.4).
4. **D/Y/B renkleri 4 sözlük** ve "Boş" siyah/gri arasında gidip geliyor (bkz. 1.6). `my_test_result_detail_screen.dart:325-333` "Doğru Sayısı" yeşil değil lacivert, "Yanlış" kırmızı.
5. **Yarıçap karmaşası.** Ders kartı dış 9 / InkWell 16 (`home_lessons_cards.dart:377` vs `:371`) ve iskelet 16 (`:465`). Stat kartı 12/6 (`stats_grid.dart:53,66`). Grafik kartları 8 (`net_chart_card.dart:135`), menü 16, kişi kartı 12, filtre paneli 20, bilgi kartı 24. Analiz sekmesi 7 (`analytics_tabs.dart:33,43`). Giriş butonu 15 (`login_card.dart:381`) vs input 12.
6. **Nav göstergesi (#FF7A00) ile nav ikon/etiketi (#FF6600) farklı turuncu** (`custom_bottom_nav_bar.dart:80` vs `:184`). Koç ikonları Material (`:107,127`), öğrenci ikonları SVG. Alt nav gölgesi pozitif Y (`:34-40`), çubuğun altında kalıyor.
7. **`AppColors` token'ları iddiasından farklı.** `menuCardBackground` dokümanında "menü kartları" yazıyor (`app_colors.dart:11`) ama menü kutucuğu beyaz + `grey.shade200` (`home_menu_grid.dart:250-257`). `shadowLight`/`shadowMedium` neredeyse aynı (0x14/0x16). `AppColors.primary` yalnızca yorumda (`app_theme.dart:21`, tanımsız).
8. **`iconBg` ölü veri.** `home_menu_grid.dart:17-81` her öğe için pastel daire rengi tanımlıyor, `_IconCircle` hiç kullanmıyor (:300-317).
9. **Ölü/kopya ekranlar.** `lib/views/auth/login_view.dart` (içinde `LoginView` + `RegisterView`) ve `AU/screens/login_screen.dart` aynı `LoginView` adını taşıyor. `lib/views/onboarding/onboarding_page.dart` ile `lib/features/onboarding/onboarding_page.dart` aynı `OnboardingScreen`. `main.dart` yalnızca `features/` olanları import ediyor, `views/auth` ve `views/onboarding` ölü. Hex sayımlarını şişiriyor.
10. **Ölü kod.** `home_lessons_cards.dart:100-207` (`_showTypeSelection`, `_showMiddleDialog`, `_showBottomPanel`), `general_filter_panel.dart:467` (`showBlurredFilterDialog`), `omd_result_flow_view.dart:187-188` (`kDarkPurpleBg` #512DA8 / `kCardPurple` #673AB7, tanımlı ama kullanılmıyor, uygulamanın tek mor tonu).
11. **Eksik asset referansları (diskte yok):** `assets/login_img.png` (`login_view.dart:132`, yorumda), `assets/default.png` (`my_test_results_detail_widgets.dart:1222`), `assets/ayt_biyoloji/cografya/fizik/geometri/kimya/matematik.png` (`my_test_results_detail_widgets.dart:1136-1156`), `assets/history.png`, `assets/math.png`, `assets/science.png`, `assets/turkish.png` (`my_card_dummy_data.dart:64-67`), `assets/icons/tag.svg`, `trophy.svg`, `chart.svg`, `check_all.svg` (`analytics_general_data.dart:54-69`), `assets/images/analiz.png` (`home_menu_grid.dart:118`, yorumda), `assets/avatars/avatar1.png` (`register_form.dart:177`). Ayrıca `assets/smapLogo.png` (`login_view.dart:110`) dosya adı büyük/küçük harf uyumsuz: diskte `smaplogo.png`; macOS'ta çalışır, Android/Linux'ta bulunamaz (ölü dosyada olduğu için etkisi şimdilik yok).
12. **Pubspec boşlukları.** `assets/authors/cpm/` (5 dosya) ve `assets/tutorial/` tanımlı değil. Kök `assets/` hem tüm `.zip`'leri hem 7,7 MB `ob*.png`'yi hem 40 logo varyantını pakete alıyor. `cupertino_icons` kullanılmıyor.
13. **Metin hataları.** "Dagilimlari/Siralama/Dogru/Turkce" (bkz. 2). "Smap" (`main.dart:84`, `title`) / "SMAP" (`login_card.dart:~245`, onboarding) / "Student map" (logo) adı üç şekilde yazılı.
14. **Font ailesi hiç belirlenmemiş.** Cihaza göre Roboto/SF. Marka görselleri geometrik sans (Montserrat/Poppins benzeri) kullanıyor, uygulama ise bununla eşleşmiyor.
15. **Tema seed'i ne marka ne vurgu** (#7D858D, `app_theme.dart:10`). Elle stillendirilmemiş bileşenler gri-mavi tonlara düşüyor (ChoiceChip, DatePicker, TimePicker).
16. **Birincil buton rengi yok.** Lacivert, soluk gri-mavi, indigo (`app_dialog.dart:13`), slate-mavi ve turuncu karışık (bkz. 5.3).
17. **AppBar türleri.** Özel `CustomTopAppBar`, `MyCardHeader` içindeki kopyası ve 5 ayrı Material `AppBar` (biri renksiz, `coach_analytics_screen.dart:26`).
18. **İkon stili.** SVG (Iconsax duotone 24 px, 16 px dolgu, 28 px turuncu, potrace siyah) + Material (rounded/outlined/filled karışık) + düz PNG illüstrasyon (28 px'te çok detaylı) + 3B avatarlar + stok menü illüstrasyonları. Tek bir ikon dili yok (bkz. 4.2).
19. **Ders ikon eşlemesi hataları.** `icon3.png` hem Coğrafya, hem Matematik, hem Geometri (`lesson_constants.dart:144,159,174,266,296,311,326`). Dersin `lessonName.substring(4)` ile "TYT "/"AYT " öneki kesiliyor (`my_card_lesson_grid_item.dart:~58`).
20. **Gölge alfaları.** `shadowLight`, `shadowMedium` + 6 farklı `Colors.black.withOpacity(x)` (bkz. 3.3). 75 `withOpacity` (deprecated) ve 15 `withValues` karışık.
21. **Aynı gradyan 4 kopya.** `lesson_bar.dart:200`, `lesson_detail_page.dart:713`, `edebiyat_lesson_detail_page.dart:909`, `subject_detail_page.dart:454`.
22. **Duyarlılık.** İki bileşen kendi ölçeklemesini yazmış (`stats_grid.dart:41`, `lesson_distribution_chart_card.dart:19-24`), geri kalan her yer sabit px.
23. **Sayfa gutter'ı** 16/20/24/40 (bkz. 3.1).
24. **Logo kullanımı.** `smaplogo.png` şeffaf, tuvalinde çok boşluk, 40 px'te küçük kalıyor ve lacivert barda logonun lacivert yarısı zeminle birleşiyor (`header_user_section.dart:51-56`). Launcher ikonu kaynağı wordmark'lı `logotext.png` (`pubspec.yaml:81`).
25. **Debug izleri.** 73 `print(` çağrısı kodda duruyor (ör. `root_screen.dart:77`, `interview_detail_screen.dart:524`).

---

## Dosya yolları

- Repo: `.`
- Tema: `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`
- Ders sabitleri: `lib/core/constants/lesson_constants.dart`
- Giriş: `lib/main.dart`
- Pubspec: `pubspec.yaml`
- Asset kökü: `assets`
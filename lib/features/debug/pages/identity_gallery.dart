import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/gen/assets.gen.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/identity/app_avatar_picker.dart';
import 'package:smap/shared/ui/identity/app_avatar_stack.dart';
import 'package:smap/shared/ui/identity/app_logo.dart';

/// Gallery page of identity: `AppAvatar` (C55), `AppAvatarStack` (C56),
/// `AppAvatarPicker` (C57), pano 1.17, and `AppLogoMark` / `AppLockup` (C59),
/// pano 1.26.
class IdentityGallery extends StatefulWidget {
  const IdentityGallery({super.key});

  @override
  State<IdentityGallery> createState() => _IdentityGalleryState();
}

class _IdentityGalleryState extends State<IdentityGallery> {
  var _avatar = 0;

  static final List<ImageProvider> _avatars = [
    Assets.avatars.a1avatarN3.provider(),
    Assets.avatars.a3avatarN3.provider(),
    Assets.avatars.a4avatarN3.provider(),
    Assets.avatars.a5avatarN3.provider(),
    Assets.avatars.a6avatarN3.provider(),
    Assets.avatars.a8avatarN3.provider(),
    Assets.avatars.a9avatarN3.provider(),
  ];

  @override
  Widget build(BuildContext context) {
    final people = <AvatarPerson>[
      (name: 'Elif Şahin', image: _avatars[3]),
      (name: 'Kerem Aydın', image: _avatars[2]),
      (name: 'Zeynep Kaya', image: _avatars[4]),
      (name: 'Mert Demir', image: _avatars[1]),
      (name: 'Işıl Yıldız', image: null),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppAvatar · C55 · pano 1.17',
          note:
              'Boylar 24 · 32 · 40 · 56 · 96. Görsel yoksa baş harfler. Koç '
              'rozeti bir kelime: "Koç".',
          children: [
            GalleryWrap(
              children: [
                for (final size in const [
                  AppAvatarSize.xs,
                  AppAvatarSize.sm,
                  AppAvatarSize.md,
                  AppAvatarSize.lg,
                  AppAvatarSize.xl,
                ])
                  AppAvatar(
                    name: 'Alparslan Kuloğlu',
                    image: _avatars[0],
                    size: size,
                  ),
              ],
            ),
            GalleryState(
              label: 'Baş harf yedeği',
              child: GalleryWrap(
                children: [
                  for (final size in const [
                    AppAvatarSize.xs,
                    AppAvatarSize.sm,
                    AppAvatarSize.md,
                    AppAvatarSize.lg,
                    AppAvatarSize.xl,
                  ])
                    AppAvatar(name: 'Alparslan Kuloğlu', size: size),
                ],
              ),
            ),
            GalleryState(
              label: 'Koç',
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s16),
                child: Row(
                  children: [
                    AppAvatar(
                      name: 'Mehmet Özkan',
                      image: _avatars[1],
                      coach: true,
                    ),
                    const SizedBox(width: 24),
                    const AppAvatar(name: 'Mehmet Özkan', coach: true),
                  ],
                ),
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppAvatarStack · C56 · pano 1.17',
          note: 'En çok 3 avatar ve "+N"; 2 pt beyaz halka, 8 pt bindirme.',
          children: [
            AppAvatarStack(people: people),
            AppAvatarStack(people: people.take(2).toList()),
            GalleryPanel(
              tone: GalleryTone.canvas,
              child: AppAvatarStack.large(people: people),
            ),
          ],
        ),
        GallerySection(
          title: 'AppAvatarPicker · C57 · pano 1.17',
          note:
              '7 avatar birden görünür, sayısı yazılır. Seçili: 2 pt boşluk + '
              '2 pt lacivert halka.',
          children: [
            AppAvatarPicker(
              avatars: _avatars,
              selectedIndex: _avatar,
              onChanged: (i) => setState(() => _avatar = i),
            ),
            AppAvatarPicker(
              avatars: _avatars,
              selectedIndex: _avatar,
              size: 48,
              onChanged: (i) => setState(() => _avatar = i),
            ),
          ],
        ),
        GallerySection(
          title: 'AppLogoMark · AppLockup · C59 · pano 1.26',
          note:
              'S-rota: solda lacivert, sağda turuncu üstten geçer. Uygulama '
              'içinde en küçük boy 20 pt; yalnız açılışta ve girişte.',
          children: [
            GalleryWrap(
              children: [
                for (final height in const [20.0, 29.0, 40.0, 64.0])
                  AppLogoMark(height: height),
              ],
            ),
            GalleryPanel(
              tone: GalleryTone.navy,
              child: GalleryWrap(
                children: [
                  for (final height in const [20.0, 40.0, 64.0])
                    AppLogoMark(height: height, tone: AppLogoTone.onNavy),
                ],
              ),
            ),
            const GalleryWrap(
              children: [AppLogoMark(height: 40, tone: AppLogoTone.monoNavy)],
            ),
            const GalleryPanel(
              tone: GalleryTone.navy,
              child: AppLogoMark(height: 40, tone: AppLogoTone.monoWhite),
            ),
            const GalleryPanel(tone: GalleryTone.canvas, child: AppLockup()),
            const GalleryPanel(
              tone: GalleryTone.navy,
              child: AppLockup(onNavy: true),
            ),
            const GalleryPanel(
              tone: GalleryTone.navy,
              child: Center(
                child: AppLockup(
                  layout: AppLockupLayout.vertical,
                  onNavy: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

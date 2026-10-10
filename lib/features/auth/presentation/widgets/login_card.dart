import 'package:flutter/material.dart';
import 'package:smap/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smap/features/auth/presentation/widgets/auth_enums.dart';
import 'package:smap/features/auth/presentation/widgets/register_form.dart';
import 'package:smap/features/auth/presentation/widgets/social_provider_icon.dart';
import 'package:smap/features/auth/presentation/widgets/social_sign_up_content.dart';

import 'package:provider/provider.dart'; // ChangeNotifierProvider ve context.read için
import 'package:smap/features/auth/domain/usecases/register_usecase.dart'; // RegisterUseCase için
import 'package:smap/features/auth/presentation/provider/register_provider.dart'; // RegisterNotifier için (dosya yolun farklıysa ona göre düzenle)
import 'package:smap/features/auth/domain/usecases/get_legal_documents_usecase.dart'; // RegisterUseCase için

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoading,
    required this.onRememberMeChanged,
    required this.onLoginPressed,
    required this.cardContent,
    required this.onRegisterPressed,
    required this.onAppleSignInPressed,
    required this.onGoogleSignInPressed,
    required this.onBackToLoginPressed,
    required this.onRegisterSuccess,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoading;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onLoginPressed;
  final LoginCardContent cardContent;
  final VoidCallback onRegisterPressed;
  final VoidCallback onAppleSignInPressed;
  final VoidCallback onGoogleSignInPressed;
  final VoidCallback onBackToLoginPressed;
  final VoidCallback onRegisterSuccess; // Yeni eklenen değişken

  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.sizeOf(context).height;
    final double screenW = MediaQuery.sizeOf(context).width;

    final bool isSmall = screenH < 640;
    final bool isTiny = screenH < 520;

    final double logoH = isTiny
        ? 28
        : isSmall
        ? 36
        : (screenH * 0.06).clamp(36.0, 50.0);
    final double imageH = isTiny
        ? 70
        : isSmall
        ? 100
        : (screenH * 0.22).clamp(100.0, 170.0);
    final double spaceXs = isTiny
        ? 3
        : isSmall
        ? 5
        : (screenH * 0.008).clamp(4.0, 8.0);
    final double spaceSm = isTiny
        ? 6
        : isSmall
        ? 9
        : (screenH * 0.012).clamp(6.0, 12.0);
    final double spaceMd = isTiny
        ? 10
        : isSmall
        ? 13
        : (screenH * 0.018).clamp(10.0, 18.0);
    final double cardHPad = (screenW * 0.055).clamp(16.0, 24.0);
    final double cardVPad = isTiny
        ? 10
        : isSmall
        ? 14
        : (screenH * 0.028).clamp(12.0, 24.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSocial =
            cardContent == LoginCardContent.socialApple ||
            cardContent == LoginCardContent.socialGoogle;
        final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: bottomInset + 8,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: isSocial
                  ? constraints.maxHeight - bottomInset - 16
                  : 0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: cardHPad,
                    vertical: cardVPad,
                  ),
                  child: switch (cardContent) {
                    LoginCardContent.register =>
                      ChangeNotifierProvider<RegisterNotifier>(
                        create: (context) => RegisterNotifier(
                          registerUseCase: context.read<RegisterUseCase>(),
                          getLegalDocumentsUseCase: context
                              .read<GetLegalDocumentsUseCase>(),
                        )..fetchLegalDocuments(), // Ekran açıldığında yasal metinleri otomatik çeker
                        child: Consumer<RegisterNotifier>(
                          builder: (context, registerNotifier, child) {
                            // Burada registerState'i kontrol edip callback'i tetikliyoruz
                            final state = registerNotifier.state;

                            if (state.isSuccess) {
                              // Çakışmaları önlemek için frame çiziminden hemen sonra tetikleyelim
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                onRegisterSuccess();
                              });
                            }

                            return RegisterForm(
                              onBackPressed: onBackToLoginPressed,
                            );
                          },
                        ),
                      ),
                    LoginCardContent.socialApple => SocialSignUpContent(
                      provider: SocialProvider.apple,
                      onBackPressed: onBackToLoginPressed,
                    ),
                    LoginCardContent.socialGoogle => SocialSignUpContent(
                      provider: SocialProvider.google,
                      onBackPressed: onBackToLoginPressed,
                    ),
                    LoginCardContent.login => _LoginFormContent(
                      formKey: formKey,
                      usernameController: usernameController,
                      passwordController: passwordController,
                      rememberMe: rememberMe,
                      isLoading: isLoading,
                      onRememberMeChanged: onRememberMeChanged,
                      onLoginPressed: onLoginPressed,
                      onRegisterPressed: onRegisterPressed,
                      onAppleSignInPressed: onAppleSignInPressed,
                      onGoogleSignInPressed: onGoogleSignInPressed,
                      logoH: logoH,
                      imageH: imageH,
                      spaceXs: spaceXs,
                      spaceSm: spaceSm,
                      spaceMd: spaceMd,
                    ),
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Login form içeriği (karta özgü, dışarıdan erişilmez)
// ---------------------------------------------------------------------------

class _LoginFormContent extends StatelessWidget {
  const _LoginFormContent({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoading,
    required this.onRememberMeChanged,
    required this.onLoginPressed,
    required this.onRegisterPressed,
    required this.onAppleSignInPressed,
    required this.onGoogleSignInPressed,
    required this.logoH,
    required this.imageH,
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoading;
  final ValueChanged<bool?> onRememberMeChanged;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;
  final VoidCallback onAppleSignInPressed;
  final VoidCallback onGoogleSignInPressed;
  final double logoH;
  final double imageH;
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;

  static const Color _darkBlue = Color(0xFF0D2744);
  static const Color _inputFill = Color(0xFFE8F1FA);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/smaplogo.png', height: logoH),
        SizedBox(height: spaceSm),
        const Text(
          "SMAP'e hoş geldin!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _darkBlue,
          ),
        ),
        SizedBox(height: spaceXs),
        Text(
          'Öğrenme yolculuğunuza başlamaya hazır mısınız?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: spaceSm),
        Image.asset('assets/loginImage.png', height: imageH),
        SizedBox(height: spaceMd),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Kullanıcı Girişi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _darkBlue,
            ),
          ),
        ),
        SizedBox(height: spaceSm),
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Kullanıcı adı',
                  filled: true,
                  fillColor: _inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
              SizedBox(height: spaceSm),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onLoginPressed(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  filled: true,
                  fillColor: _inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spaceXs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 22,
                  width: 22,
                  child: Checkbox(
                    value: rememberMe,
                    activeColor: _darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: onRememberMeChanged,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Beni Hatırla', style: TextStyle(fontSize: 12)),
              ],
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'Şifremi unuttum',
                style: TextStyle(color: _darkBlue, fontSize: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: spaceXs),
        Text(
          'veya hesabınızla bağlanın',
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
        SizedBox(height: spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onAppleSignInPressed,
              child: const SocialProviderIcon(provider: SocialProvider.apple),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onGoogleSignInPressed,
              child: const SocialProviderIcon(provider: SocialProvider.google),
            ),
          ],
        ),
        SizedBox(height: spaceMd),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
            ),
            onPressed: isLoading ? null : onLoginPressed,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hesabın yok mu? ', style: TextStyle(fontSize: 13)),
            GestureDetector(
              onTap: onRegisterPressed,
              child: const Text(
                'Kayıt ol',
                style: TextStyle(
                  color: _darkBlue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

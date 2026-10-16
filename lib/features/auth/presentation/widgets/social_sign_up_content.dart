import 'package:flutter/material.dart';
import 'package:studentmap/features/auth/presentation/widgets/auth_enums.dart';
import 'package:studentmap/features/auth/presentation/widgets/role_toggle_button.dart';
import 'package:studentmap/features/auth/presentation/widgets/social_provider_icon.dart';

class SocialSignUpContent extends StatefulWidget {
  const SocialSignUpContent({
    super.key,
    required this.provider,
    required this.onBackPressed,
  });

  final SocialProvider provider;
  final VoidCallback onBackPressed;

  @override
  State<SocialSignUpContent> createState() => _SocialSignUpContentState();
}

class _SocialSignUpContentState extends State<SocialSignUpContent> {
  static const Color _darkBlue = Color(0xFF0D2744);

  RegisterRole _role = RegisterRole.student;

  String get _continueButtonLabel => _role == RegisterRole.student
      ? 'Öğrenci Olarak Devam Et'
      : 'Öğrenci Koçu Olarak Devam Et';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _darkBlue,
                size: 22,
              ),
              onPressed: widget.onBackPressed,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: SocialProviderIcon(provider: widget.provider)),
        const SizedBox(height: 20),
        const Text(
          'Kayıt için son bir adım!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Son bir adım kaldı! Devam etmek için kendinizi tanımlayın.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: RoleToggleButton(
                label: 'Öğrenci',
                selected: _role == RegisterRole.student,
                onTap: () => setState(() => _role = RegisterRole.student),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RoleToggleButton(
                label: 'Öğrenci Koçu',
                selected: _role == RegisterRole.coach,
                onTap: () => setState(() => _role = RegisterRole.coach),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {},
            child: Text(
              _continueButtonLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

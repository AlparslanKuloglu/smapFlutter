import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Sabitler
// ---------------------------------------------------------------------------

const Color _kDarkBlue = Color(0xFF0D2744);
const Color _kInputFill = Color(0xFFE8F1FA);

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: _kInputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  );
}

ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: _kDarkBlue,
    disabledBackgroundColor: Colors.grey.shade300,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    elevation: 0,
  );
}

// ---------------------------------------------------------------------------
// Ana sayfa – adım yönetimi
// ---------------------------------------------------------------------------

enum _ForgotStep { phone, verify, newPassword, success }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _ForgotStep _step = _ForgotStep.phone;
  String _phone = '';

  void _goToVerify(String phone) => setState(() {
        _phone = phone;
        _step = _ForgotStep.verify;
      });

  void _goToNewPassword() => setState(() => _step = _ForgotStep.newPassword);

  void _goToSuccess() => setState(() => _step = _ForgotStep.success);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: bottomInset + 8,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - bottomInset - 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
                          child: switch (_step) {
                            _ForgotStep.phone => _PhoneStep(
                                onContinue: _goToVerify,
                              ),
                            _ForgotStep.verify => _VerifyStep(
                                phone: _phone,
                                onVerified: _goToNewPassword,
                              ),
                            _ForgotStep.newPassword => _NewPasswordStep(
                                onSaved: _goToSuccess,
                              ),
                            _ForgotStep.success => _SuccessStep(
                                onLogin: () => Navigator.pop(context),
                              ),
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              left: 8,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _kDarkBlue,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Adım 1 – Telefon numarası
// ---------------------------------------------------------------------------

class _PhoneStep extends StatefulWidget {
  const _PhoneStep({required this.onContinue});
  final void Function(String phone) onContinue;

  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Şifremi Unuttum',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Doğrulama kodu almak için telefon numaranızı girin.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDecoration('Telefon numaranız'),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: _buttonStyle(),
            onPressed: () {
              final phone = _controller.text.trim();
              if (phone.isNotEmpty) widget.onContinue(phone);
            },
            child: const Text(
              'Devam Et',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Adım 2 – Kod doğrulama
// ---------------------------------------------------------------------------

class _VerifyStep extends StatefulWidget {
  const _VerifyStep({required this.phone, required this.onVerified});
  final String phone;
  final VoidCallback onVerified;

  @override
  State<_VerifyStep> createState() => _VerifyStepState();
}

class _VerifyStepState extends State<_VerifyStep> {
  static const int _codeLength = 4;
  static const int _countdownSeconds = 30;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  int _secondsLeft = _countdownSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _secondsLeft = _countdownSeconds;
    _canResend = false;
    _tick();
  }

  void _tick() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
          _tick();
        } else {
          _canResend = true;
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredCode => _controllers.map((c) => c.text).join();
  bool get _codeComplete => _enteredCode.length == _codeLength;

  String get _maskedPhone {
    final p = widget.phone;
    if (p.length <= 4) return p;
    return '${'*' * (p.length - 4)}${p.substring(p.length - 4)}';
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _verify() {
    if (!_codeComplete) return;
    // Gerçek doğrulama burada yapılır; şimdilik her kod geçerli.
    widget.onVerified();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Telefon Doğrulama',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Doğrulama kodu şu numaraya gönderildi: $_maskedPhone',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_codeLength, (i) {
            return Container(
              width: 56,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                onChanged: (v) => _onCodeChanged(v, i),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: _kInputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kDarkBlue, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _kDarkBlue,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: _buttonStyle(),
            onPressed: _codeComplete ? _verify : null,
            child: const Text(
              'Kodu Onayla',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _canResend
                  ? 'Kodu almadınız mı? '
                  : 'Tekrar gönder ($_secondsLeft sn)',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            if (_canResend)
              GestureDetector(
                onTap: () => setState(_startCountdown),
                child: const Text(
                  'Tekrar Gönder',
                  style: TextStyle(
                    fontSize: 13,
                    color: _kDarkBlue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Adım 3 – Yeni şifre
// ---------------------------------------------------------------------------

class _NewPasswordStep extends StatefulWidget {
  const _NewPasswordStep({required this.onSaved});
  final VoidCallback onSaved;

  @override
  State<_NewPasswordStep> createState() => _NewPasswordStepState();
}

class _NewPasswordStepState extends State<_NewPasswordStep> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool get _canSave =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmController.text;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Yeni Şifre',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lütfen yeni şifrenizi girin.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration('Şifre'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          decoration: _inputDecoration('Şifre tekrar'),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: _buttonStyle(),
            onPressed: _canSave ? widget.onSaved : null,
            child: const Text(
              'Şifreyi Onayla',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Adım 4 – Başarı
// ---------------------------------------------------------------------------

class _SuccessStep extends StatelessWidget {
  const _SuccessStep({required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.green,
          size: 72,
        ),
        const SizedBox(height: 20),
        const Text(
          'Şifre Değiştirildi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _kDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Şifreniz başarıyla değiştirildi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: _buttonStyle(),
            onPressed: onLogin,
            child: const Text(
              'Giriş Yap',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

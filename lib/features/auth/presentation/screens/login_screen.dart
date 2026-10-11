import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smap/features/auth/presentation/provider/login_provider.dart';
import 'package:smap/features/auth/presentation/widgets/auth_enums.dart';
import 'package:smap/features/auth/presentation/widgets/login_card.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  LoginCardContent _cardContent = LoginCardContent.login;
  LoginNotifier? _loginNotifier;
  String? _lastHandledError;
  bool _handledSuccess = false;

  Future<void> _loginAction() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<LoginNotifier>().login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );
  }

  // Giriş başarılı: ekranı değiştiren artık bu ekran değil. Oturum
  // `SessionManager`'da açıldı; router'ın guard zinciri (`lib/app/router`)
  // rol kabuğunu kendisi açar, `UserProvider` da oturumdan beslenir
  // (`lib/features/legacy/legacy_user_bridge.dart`).
  Future<void> _onLoginSuccess() async {}

  // Kayıt başarılı: oturum kayıttan hemen sonra `SessionManager`'da açıldı;
  // yönlendirmeyi router yapar. Burada yalnız bilgi mesajı kalır.
  Future<void> _onRegisterSuccess() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıt başarılı! Giriş yapıldı.')),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = context.read<LoginNotifier>();
    if (_loginNotifier != notifier) {
      _loginNotifier?.removeListener(_onLoginStateChanged);
      _loginNotifier = notifier;
      _loginNotifier?.addListener(_onLoginStateChanged);
    }
  }

  void _onLoginStateChanged() {
    final state = _loginNotifier?.state;
    if (state == null) return;
    if (state.isSuccess && !_handledSuccess) {
      _handledSuccess = true;
      _onLoginSuccess();
      return;
    }
    final error = state.errorMessage;
    if (error != null && error != _lastHandledError) {
      _lastHandledError = error;
      _showError(error);
    }
  }

  @override
  void dispose() {
    _loginNotifier?.removeListener(_onLoginStateChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0D2744);
    const Color bgColor = Color(0xFFF0F4F8);
    final LoginState loginState = context.watch<LoginNotifier>().state;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: const ColoredBox(color: darkBlue),
          ),
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.5,
            left: 0,
            right: 0,
            bottom: 0,
            child: const ColoredBox(color: bgColor),
          ),
          SafeArea(
            child: LoginCard(
              formKey: _formKey,
              usernameController: _usernameController,
              passwordController: _passwordController,
              rememberMe: _rememberMe,
              isLoading: loginState.isLoading,
              onRememberMeChanged: (val) =>
                  setState(() => _rememberMe = val ?? false),
              onLoginPressed: _loginAction,
              onRegisterSuccess: _onRegisterSuccess,
              cardContent: _cardContent,
              onRegisterPressed: () =>
                  setState(() => _cardContent = LoginCardContent.register),
              onAppleSignInPressed: () =>
                  setState(() => _cardContent = LoginCardContent.socialApple),
              onGoogleSignInPressed: () =>
                  setState(() => _cardContent = LoginCardContent.socialGoogle),
              onBackToLoginPressed: () =>
                  setState(() => _cardContent = LoginCardContent.login),
            ),
          ),
        ],
      ),
    );
  }
}

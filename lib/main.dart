import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:smap/core/bloc/app_bloc_observer.dart';
import 'package:smap/core/theme/app_theme.dart';
import 'package:smap/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:smap/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smap/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:smap/features/auth/domain/usecases/complete_onboarding_usecase.dart';
import 'package:smap/features/auth/domain/usecases/get_app_launch_destination_usecase.dart';
import 'package:smap/features/auth/domain/usecases/get_legal_documents_usecase.dart'; // 👈 EKLENDİ
import 'package:smap/features/auth/domain/usecases/login_usecase.dart';
import 'package:smap/features/auth/domain/usecases/logout_usecase.dart';
import 'package:smap/features/auth/domain/usecases/register_usecase.dart';

import 'package:smap/features/auth/presentation/screens/login_screen.dart';
import 'package:smap/features/auth/presentation/provider/app_start_provider.dart';
import 'package:smap/features/auth/presentation/provider/login_provider.dart';
import 'package:smap/features/home/presentation/provider/home_provider.dart';
import 'package:smap/features/onboarding/onboarding_page.dart';
import 'package:smap/features/root/presentation/screens/root_screen.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart';
import 'package:smap/repository/profile_repository.dart';
import 'package:smap/repository/cards_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:smap/core/network/dio_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DioClient().init();
  await initializeDateFormatting('tr_TR');
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localDataSource = AuthLocalDataSource();
    final remoteDataSource = AuthRemoteDataSource();
    final userProvider = UserProvider();

    final repository = AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      userProvider: userProvider,
    );
    final profileRepository = ProfileRepository();
    final cardsRepository = CardsRepository();

    return MultiProvider(
      providers: [
        Provider<AuthRepositoryImpl>.value(value: repository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<CardsRepository>.value(value: cardsRepository),

        Provider<CompleteOnboardingUseCase>(
          create: (_) => CompleteOnboardingUseCase(repository),
        ),
        Provider<LoginUseCase>(create: (_) => LoginUseCase(repository)),
        Provider<RegisterUseCase>(create: (_) => RegisterUseCase(repository)),

        // 👈 YENİ EKLENEN USE CASE PROVIDER
        Provider<GetLegalDocumentsUseCase>(
          create: (_) => GetLegalDocumentsUseCase(repository),
        ),

        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider<LogoutUseCase>(create: (_) => LogoutUseCase(repository)),
        ChangeNotifierProvider<AppStartNotifier>(
          create: (_) =>
              AppStartNotifier(GetAppLaunchDestinationUseCase(repository))
                ..resolveStartRoute(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smap',
          theme: AppTheme.light,

          // --- TÜRKÇE DİL VE LOCALIZATION AYARLARI ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr', 'TR')],
          locale: const Locale('tr', 'TR'),

          // -------------------------------------------
          routes: {
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (context) => ChangeNotifierProvider(
              create: (context) => LoginNotifier(context.read<LoginUseCase>()),
              child: const LoginView(),
            ),
            '/home': (context) => Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final role = userProvider.userRole;
                if (role == null) {
                  userProvider.loadUserData();
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return RootScreen(
                  profileRepository: context.read<ProfileRepository>(),
                  userRole: role,
                );
              },
            ),
          },
          home: Consumer<AppStartNotifier>(
            builder: (context, appStartNotifier, _) {
              final state = appStartNotifier.state;
              if (state.isLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              switch (state.destination) {
                case AppLaunchDestination.onboarding:
                  return const OnboardingScreen();
                case AppLaunchDestination.login:
                  return ChangeNotifierProvider(
                    create: (context) =>
                        LoginNotifier(context.read<LoginUseCase>()),
                    child: const LoginView(),
                  );
                case AppLaunchDestination.home:
                  return Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      final role = userProvider.userRole;
                      if (role == null) {
                        userProvider.loadUserData();
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return RootScreen(
                        profileRepository: context.read<ProfileRepository>(),
                        userRole: role,
                      );
                    },
                  );
              }
            },
          ),
        );
      },
    );
  }
}

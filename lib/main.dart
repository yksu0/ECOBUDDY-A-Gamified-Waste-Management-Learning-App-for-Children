import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/pet_provider.dart';
import 'services/achievement_service.dart';
import 'services/challenge_service.dart';
import 'services/almanac_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final achievementService = AchievementService();
  final challengeService = ChallengeService();
  final almanacService = AlmanacService();
  
  await achievementService.initialize();
  await challengeService.initialize();
  await almanacService.initialize();
  
  runApp(EcoBuddyApp(
    achievementService: achievementService,
    challengeService: challengeService,
    almanacService: almanacService,
  ));
}

class EcoBuddyApp extends StatelessWidget {
  final AchievementService achievementService;
  final ChallengeService challengeService;
  final AlmanacService almanacService;
  
  const EcoBuddyApp({
    super.key, 
    required this.achievementService,
    required this.challengeService,
    required this.almanacService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final petProvider = PetProvider();
            petProvider.setAchievementService(achievementService);
            petProvider.setChallengeService(challengeService);
            return petProvider;
          },
        ),
        ChangeNotifierProvider.value(value: achievementService),
        ChangeNotifierProvider.value(value: challengeService),
        ChangeNotifierProvider.value(value: almanacService),
      ],
      child: MaterialApp(
        title: 'EcoBuddy',
        // Force English locale - overrides system settings
        locale: const Locale('en', 'US'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English only
        ],
        // Fallback locale in case of issues
        localeResolutionCallback: (locale, supportedLocales) {
          // Always return English regardless of device locale
          return const Locale('en', 'US');
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

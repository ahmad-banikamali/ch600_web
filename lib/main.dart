import 'package:ch600/ui/screens/home_screen.dart';
import 'package:ch600/utils/constants.dart';
import 'package:ch600/utils/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("fa", "IR"),
      ],
      locale: const Locale("fa", "IR"),
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
              primaryColor: Colors.black,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
              useMaterial3: true,
              appBarTheme:
                  const AppBarTheme().copyWith(backgroundColor: Colors.black87))
          .copyWith(
              textTheme: const TextTheme().copyWith(
                  titleMedium: const TextStyle(
                      color: Colors.white,
                      fontFamily: "bYekan",
                      fontSize: 20
                  ))),
      home: const HomeScreen(),
      // home: showLockScreen ?   LockScreen() :   SettingsScreen(),
    );
  }
}



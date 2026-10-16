import 'package:flutter/material.dart';

import 'screens.dart';
import 'store.dart';
import 'ui.dart';

class PlativoApp extends StatefulWidget {
  const PlativoApp({super.key});

  @override
  State<PlativoApp> createState() => _PlativoAppState();
}

class _PlativoAppState extends State<PlativoApp> {
  final store = PlativoStore();

  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PLATIVO',
          theme: plativoTheme(Brightness.light),
          darkTheme: plativoTheme(Brightness.dark),
          themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: SplashScreen(store: store),
        );
      },
    );
  }
}

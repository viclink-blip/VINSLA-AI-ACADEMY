import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const VinslaApp());
}

class VinslaApp extends StatefulWidget {
  const VinslaApp({super.key});
  @override
  State<VinslaApp> createState() => _VinslaAppState();
}

class _VinslaAppState extends State<VinslaApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() => setState(() =>
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title:            'Vinsla AI Academy',
      debugShowCheckedModeBanner: false,
      themeMode:        _themeMode,
      theme:            AppTheme.light,
      darkTheme:        AppTheme.dark,
      routerConfig:     appRouter,
    );
  }
}

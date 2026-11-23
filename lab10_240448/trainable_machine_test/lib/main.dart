import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'services/app_controller.dart';
import 'theme/app_theme.dart';

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final Future<AppController> _loading;
  AppController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loading = AppController.create().then((controller) {
      _controller = controller;
      return controller;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _controller?.close();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teach It, Ship It',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: WelcomeScreen(loading: _loading),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ptp/provider/led_provider.dart';
import 'package:flutter_ptp/ui/pages/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LedProvider(),
      builder: (context, child) => MaterialApp(
        title: 'ad hoc App',
        theme: ThemeData(
          fontFamily: 'PlayfairDisplay',
          textTheme: const TextTheme(
            headline4: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
            bodyText1: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            bodyText2: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          appBarTheme: AppBarTheme(
            color: Colors.blue[700]!,
          ),
          progressIndicatorTheme: ProgressIndicatorThemeData(
            color: Colors.white.withOpacity(0.75),
          ),
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:template/repo/repository.dart';
import 'package:template/routes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Repository(),
      child: const App(),
    )
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Exam App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

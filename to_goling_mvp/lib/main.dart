import 'package:flutter/material.dart';
import 'services/log_repository.dart';
import 'screens/new_log_screen.dart';
import 'screens/log_detail_screen.dart';
import 'models/log_entry.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const ToGoLingApp());
}

class ToGoLingApp extends StatelessWidget {
  const ToGoLingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logRepository = LogRepository();

    return MaterialApp(
      title: 'To-GoLing',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF111827),
        fontFamily: 'Apple SD Gothic Neo',
      ),
      routes: {
        '/': (context) => MainShell(logRepository: logRepository),
        '/new': (context) => NewLogScreen(logRepository: logRepository),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final log = settings.arguments as LogEntry;
          return MaterialPageRoute(
            builder: (context) => LogDetailScreen(log: log),
          );
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart'; // 딥링크 패키지
import 'services/log_repository.dart';
import 'screens/new_log_screen.dart';
import 'screens/log_detail_screen.dart';
import 'models/log_entry.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart'; // 메인 쉘 import

void main() {
  runApp(const ToGoLingApp());
}

// 딥링크 감지를 위해 StatefulWidget으로 변경
class ToGoLingApp extends StatefulWidget {
  const ToGoLingApp({super.key});

  @override
  State<ToGoLingApp> createState() => _ToGoLingAppState();
}

class _ToGoLingAppState extends State<ToGoLingApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  // 딥링크(NFC) 초기화 로직
  void _initDeepLinks() async {
    _appLinks = AppLinks();

    // 1. 앱이 꺼져있을 때 NFC로 켠 경우
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleLink(initialUri);
      }
    } catch (e) {
      debugPrint("초기 링크 에러: $e");
    }

    // 2. 앱이 켜져있을 때 NFC 태그한 경우 (스트림 리스너)
    _appLinks.uriLinkStream.listen((uri) {
      _handleLink(uri);
    });
  }

  // 링크 처리 함수
  void _handleLink(Uri uri) {
    if (uri.scheme == 'togoling' && uri.host == 'new') {
      // 0.5초 딜레이 (앱 초기화 대기)
      Future.delayed(const Duration(milliseconds: 500), () {
        // 현재 화면 스택을 다 비우고 메인(Home)을 먼저 깔고, 그 위에 New를 얹음
        // 이렇게 해야 NewLogScreen에서 뒤로가기 했을 때 메인 화면이 나옴
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/home', 
          (route) => false, 
        );
        _navigatorKey.currentState?.pushNamed('/new');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final logRepository = LogRepository();

    return MaterialApp(
      navigatorKey: _navigatorKey, // 네비게이터 키 등록 필수
      title: 'To-GoLing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F6F2),
        fontFamily: 'BlackHanSans', 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B0F19),
          background: const Color(0xFFF7F6F2),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F6F2),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0B0F19),
          ),
        ),
      ),
      routes: {
        '/': (context) => SplashScreen(logRepository: logRepository),
        '/home': (context) => MainShell(logRepository: logRepository), // 메인 화면 연결
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
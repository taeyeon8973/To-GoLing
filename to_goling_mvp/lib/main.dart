import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'services/log_repository.dart';
import 'screens/new_log_screen.dart';
import 'screens/log_detail_screen.dart';
import 'models/log_entry.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const ToGoLingApp());
}

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

  void _initDeepLinks() async {
    _appLinks = AppLinks();
    
    // [확인용] 함수가 실행되었는지 무조건 출력
    print("👀 딥링크 감지 함수 시작됨 (_initDeepLinks)");

    // 1. 스트림 리스너 먼저 등록 (놓치지 않기 위해)
    _appLinks.uriLinkStream.listen((uri) {
      print("⚡ [스트림 감지] 주소 들어옴: $uri");
      _handleLink(uri);
    }, onError: (err) {
      print("❌ [에러] 스트림 에러: $err");
    });

    // 2. 앱이 꺼져있을 때 들어온 주소 확인
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      print("🚀 [초기값 확인] getInitialLink 결과: $initialUri");
      
      if (initialUri != null) {
        _handleLink(initialUri);
      }
    } catch (e) {
      print("⚠️ 초기값 확인 중 에러: $e");
    }
  }

  void _handleLink(Uri uri) {
    print("🧐 주소 분석 중... Scheme: ${uri.scheme}, Host: ${uri.host}");

    if (uri.scheme == 'togoling' && uri.host == 'new') {
      print("✅ [성공] 조건 일치! 0.5초 뒤 이동합니다.");
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_navigatorKey.currentState != null) {
          _navigatorKey.currentState!.pushNamed('/new');
          print("🏃 이동 명령 실행 완료");
        } else {
          print("❌ 네비게이터가 아직 준비되지 않음");
        }
      });
    } else {
      print("❌ 조건 불일치 (내 주소가 아님)");
    }
  }

  @override
  Widget build(BuildContext context) {
    final logRepository = LogRepository();

    return MaterialApp(
      navigatorKey: _navigatorKey, // 키 연결 필수
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
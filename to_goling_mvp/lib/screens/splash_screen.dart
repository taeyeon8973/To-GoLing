import 'package:flutter/material.dart';
import '../services/log_repository.dart';

class SplashScreen extends StatefulWidget {
  final LogRepository logRepository;
  const SplashScreen({super.key, required this.logRepository});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // 1.5초 대기
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    // 👇 [중요 로직 유지] 
    // NFC 태그로 인해 이미 NewLogScreen으로 이동했다면, 
    // 이 코드는 실행되지 않아서 화면이 튕기지 않습니다.
    if (ModalRoute.of(context)?.isCurrent == true) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2), // 배경색 (이미지가 로딩되기 전 잠깐 보임)
      // 👇 [UI 복구] 화면 전체에 splash.png 이미지 채우기
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash/splash.png',
          fit: BoxFit.cover, // 비율 유지하면서 화면 꽉 채우기
        ),
      ),
    );
  }
}
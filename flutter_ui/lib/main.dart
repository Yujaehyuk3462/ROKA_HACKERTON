import 'package:flutter/material.dart';

import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/inventory_list_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/capture_screen.dart';
import 'widgets/bottom_nav.dart';

void main() => runApp(const DefenseInventoryApp());

class DefenseInventoryApp extends StatelessWidget {
  const DefenseInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '국방 장비 재고 관리',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainShell(),
    );
  }
}

/// 하단 탭(홈·재고·이력·설정)을 IndexedStack 으로 유지하고,
/// 가운데 촬영 버튼은 전체화면 CaptureScreen 을 push 한다.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    InventoryListScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _openCapture() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CaptureScreen(), fullscreenDialog: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBody: false,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onCamera: _openCapture,
      ),
    );
  }
}

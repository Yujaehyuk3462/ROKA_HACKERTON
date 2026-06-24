import 'package:flutter/material.dart';

/// 국방 장비 재고 관리 앱 — 색상 팔레트
/// (국방모바일보안 톤: 차콜 그레이 + 골드 + 브릭 레드)
class AppColors {
  // 배경 / 표면
  static const bg = Color(0xFF2A2A2C); // 매트 차콜 페이지 배경
  static const card = Color(0xFF363539); // 카드/패널
  static const cardAlt = Color(0xFF2F2E31); // 보조 패널 (세그먼트 등)
  static const inner = Color(0xFF3D3C40); // 내부 박스 (아이콘 배경 등)
  static const chipActive = Color(0xFF45444A); // 세그먼트 활성 배경
  static const serialRow = Color(0xFF242325); // 총번 행 배경

  // 강조색
  static const gold = Color(0xFFD8A94A); // 브랜드 / 활성 / 정상·일치 / 증가
  static const goldLight = Color(0xFFE0B45C);
  static const goldLightest = Color(0xFFECCF8E);
  static const red = Color(0xFFC0433E); // 커밋 액션 / 결손·초과 (critical)
  static const terracotta = Color(0xFFCB6B52); // 부족 / 정비요 (warning)
  static const inspectGray = Color(0xFFB5B0A8); // 전투장비지휘검열 카테고리

  // 텍스트 / 회색
  static const textPrimary = Color(0xFFECEAE4);
  static const textSub = Color(0xFF97968F);
  static const textMute = Color(0xFF6E6E70);
  static const faint = Color(0xFF5C5B5E);
  static const textSoft = Color(0xFFC8C6C0);

  // 보더
  static const border = Color(0x14FFFFFF); // ≈ rgba(255,255,255,0.08)
  static const borderSoft = Color(0x0FFFFFFF); // ≈ rgba(255,255,255,0.06)
}

/// 등폭 폰트 (수량·총번·날짜 등). pubspec 에 SplineSansMono 추가 시 교체 가능.
const String kMonoFont = 'monospace';

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'Pretendard', // pubspec 에 미등록 시 시스템 기본으로 폴백
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bg,
      primary: AppColors.gold,
      secondary: AppColors.red,
    ),
    useMaterial3: true,
  );
}

/// 자주 쓰는 텍스트 스타일 헬퍼
class T {
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: kMonoFont,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
}

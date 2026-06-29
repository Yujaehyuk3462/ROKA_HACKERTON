import 'package:flutter/foundation.dart';

@immutable
class Weapon {
  final String code;             // Firestore 문서 ID: k1 / k2 / k2c1
  final String displayName;     // Flutter 표시명: K1 / K2 / K2C1
  final String officialName;
  final String type;
  final String caliber;
  final String manufacturer;
  final String description;
  final int authorizedQuantity; // 편제 정수

  const Weapon({
    required this.code,
    required this.displayName,
    required this.officialName,
    required this.type,
    required this.caliber,
    required this.manufacturer,
    required this.description,
    required this.authorizedQuantity,
  });

  factory Weapon.fromFirestore(String code, Map<String, dynamic> data) {
    return Weapon(
      code: code,
      displayName:
          data['displayName'] as String? ?? yoloToDisplayName(code),
      officialName: data['officialName'] as String? ?? code,
      type: data['type'] as String? ?? '-',
      caliber: data['caliber'] as String? ?? '-',
      manufacturer: data['manufacturer'] as String? ?? '-',
      description: data['description'] as String? ?? '',
      authorizedQuantity:
          (data['authorizedQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  /// YOLO 클래스명(소문자) → Flutter 표시명
  static String yoloToDisplayName(String code) =>
      switch (code.toLowerCase().replaceAll(RegExp(r'[-_]'), '')) {
        'k2' => 'K2',
        'k1' || 'k1a' => 'K1',
        'k2c1' => 'K2C1',
        _ => code.toUpperCase(),
      };

  /// Firestore 응답 전까지 즉시 렌더링에 사용하는 폴백 데이터
  static const Map<String, Weapon> fallbacks = {
    'K2': Weapon(
      code: 'k2',
      displayName: 'K2',
      officialName: 'K2 소총',
      type: '돌격소총',
      caliber: '5.56x45mm NATO',
      manufacturer: 'S&T모티브',
      description: '',
      authorizedQuantity: 14,
    ),
    'K1': Weapon(
      code: 'k1',
      displayName: 'K1',
      officialName: 'K1 기관단총',
      type: '기관단총',
      caliber: '5.56x45mm',
      manufacturer: 'S&T모티브',
      description: '',
      authorizedQuantity: 8,
    ),
    'K2C1': Weapon(
      code: 'k2c1',
      displayName: 'K2C1',
      officialName: 'K2C1 소총',
      type: '돌격소총(K2 개량형)',
      caliber: '5.56x45mm NATO',
      manufacturer: 'S&T모티브',
      description: '',
      authorizedQuantity: 10,
    ),
  };
}

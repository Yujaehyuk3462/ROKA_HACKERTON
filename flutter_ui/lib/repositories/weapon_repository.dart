import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weapon.dart';

class WeaponRepository {
  WeaponRepository._();

  static final _col = FirebaseFirestore.instance.collection('weapons');

  /// weapons 컬렉션 전체를 displayName(K-2 등) 키로 실시간 스트리밍
  static Stream<Map<String, Weapon>> watchAllByDisplayName() =>
      _col.snapshots().map((snap) {
        final map = <String, Weapon>{};
        for (final doc in snap.docs) {
          final w = Weapon.fromFirestore(doc.id, doc.data());
          map[w.displayName] = w;
        }
        return map;
      });

  /// code(k1/k2/k2c1) 기준 단건 Future 조회
  static Future<Weapon?> fetchByCode(String code) async {
    final doc = await _col.doc(code).get();
    if (!doc.exists) return null;
    return Weapon.fromFirestore(doc.id, doc.data()!);
  }
}

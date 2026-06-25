import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

/// capturedAt 필드는 Firestore Timestamp(Flutter 저장) 또는
/// ISO 8601 String(Python detection_store.py 저장) 두 형태가 혼재할 수 있음
DateTime? _parseTs(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is String) return DateTime.tryParse(v);
  return null;
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('detectionRecords')
                    .orderBy('capturedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.gold, strokeWidth: 3),
                    );
                  }
                  if (snapshot.hasError) {
                    return _errorState();
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return _emptyState();
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 108),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _recordCard(docs[i], i == 0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('검사 내역',
              style: T.sans(
                  size: 22,
                  weight: FontWeight.w800,
                  letterSpacing: -0.2)),
          const SizedBox(height: 2),
          Text('촬영 저장 기록 · 최신순',
              style: T.sans(
                  size: 12.5,
                  weight: FontWeight.w500,
                  color: AppColors.textSub)),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.cardAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: const Icon(Icons.assignment_outlined,
                size: 28, color: AppColors.textSub),
          ),
          const SizedBox(height: 16),
          Text('검사 기록이 없습니다',
              style: T.sans(size: 15, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('촬영 후 저장하면 이곳에 기록됩니다',
              style: T.sans(
                  size: 13,
                  weight: FontWeight.w500,
                  color: AppColors.textSub)),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 36, color: AppColors.textSub),
          const SizedBox(height: 12),
          Text('데이터를 불러오지 못했습니다',
              style: T.sans(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.textSub)),
        ],
      ),
    );
  }

  Widget _recordCard(DocumentSnapshot doc, bool isLatest) {
    final data = doc.data() as Map<String, dynamic>;

    final weaponType = data['weaponType'] as String? ?? '-';
    final qty = (data['confirmedQuantity'] as num?)?.toInt() ?? 0;
    final authorized = (data['authorizedQuantity'] as num?)?.toInt() ?? 0;
    final condition = data['condition'] as String? ?? 'good';
    final remarks = (data['remarks'] as String? ?? '').trim();
    final dateStr = _fmtDate(_parseTs(data['capturedAt']));
    final shortage = authorized - qty;

    final conditionLabel = switch (condition) {
      'repair' => '정비요',
      'unusable' => '불용',
      _ => '양호',
    };
    final conditionColor = switch (condition) {
      'repair' => AppColors.terracotta,
      'unusable' => AppColors.red,
      _ => AppColors.gold,
    };
    final conditionIcon = switch (condition) {
      'repair' => Icons.build_outlined,
      'unusable' => Icons.block_outlined,
      _ => Icons.shield_outlined,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: isLatest
            ? AppColors.gold.withOpacity(0.08)
            : AppColors.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isLatest
                ? AppColors.gold.withOpacity(0.4)
                : AppColors.borderSoft),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: conditionColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(conditionIcon, size: 20, color: conditionColor),
          ),
          const SizedBox(width: 12),
          // 중앙 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(weaponType,
                        style: T.sans(
                            size: 15, weight: FontWeight.w700)),
                    const SizedBox(width: 7),
                    _badge(conditionLabel, conditionColor),
                    if (isLatest) ...[
                      const SizedBox(width: 6),
                      _badge('최근', AppColors.goldLight,
                          bg: AppColors.gold.withOpacity(0.18)),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  remarks.isNotEmpty ? '$dateStr · $remarks' : dateStr,
                  style: T.sans(
                      size: 12,
                      weight: FontWeight.w500,
                      color: AppColors.textSub),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // 오른쪽 수량
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(TextSpan(children: [
                TextSpan(
                    text: '$qty',
                    style: T.mono(
                        size: 18,
                        weight: FontWeight.w700,
                        color: shortage > 0
                            ? AppColors.terracotta
                            : AppColors.goldLight)),
                TextSpan(
                    text: ' / $authorized',
                    style: T.sans(
                        size: 12,
                        weight: FontWeight.w500,
                        color: AppColors.textSub)),
              ])),
              const SizedBox(height: 1),
              Text(
                shortage > 0
                    ? '부족 $shortage정'
                    : shortage < 0
                        ? '초과 ${-shortage}정'
                        : '편제 일치',
                style: T.sans(
                    size: 11,
                    weight: FontWeight.w500,
                    color: shortage != 0
                        ? AppColors.terracotta
                        : AppColors.textSub),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color, {Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg ?? color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: T.sans(
              size: 10.5, weight: FontWeight.w700, color: color)),
    );
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '-';
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}.$mm.$dd  $hh:$mi';
  }
}

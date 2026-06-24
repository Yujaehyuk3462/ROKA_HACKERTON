import 'package:flutter/material.dart';
import '../theme.dart';

/// 검사 내역 — 분기별/연도별로 재물조사·전투장비지휘검열 시점의 기종별 수량 대조
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _Inspection {
  final String label;
  final String type; // 재물조사 | 전투장비지휘검열
  final String date;
  final Map<String, int> counts;
  const _Inspection(this.label, this.type, this.date, this.counts);

  bool get isSurvey => type == '재물조사';
}

const _order = ['K-2', 'K-1A', 'K2C1', 'M16A1'];
const _auth = {'K-2': 14, 'K-1A': 8, 'K2C1': 10, 'M16A1': 6};

const _quarterly = <_Inspection>[
  _Inspection("'25 4분기", '재물조사', '2025.12.18', {'K-2': 14, 'K-1A': 8, 'K2C1': 10, 'M16A1': 6}),
  _Inspection("'26 1분기", '전투장비지휘검열', '2026.03.15', {'K-2': 14, 'K-1A': 8, 'K2C1': 10, 'M16A1': 6}),
  _Inspection("'26 2분기", '재물조사', '2026.06.22', {'K-2': 12, 'K-1A': 8, 'K2C1': 9, 'M16A1': 6}),
];

const _yearly = <_Inspection>[
  _Inspection('2024년', '재물조사', '2024.11.20', {'K-2': 14, 'K-1A': 8, 'K2C1': 10, 'M16A1': 6}),
  _Inspection('2025년', '전투장비지휘검열', '2025.10.14', {'K-2': 13, 'K-1A': 8, 'K2C1': 10, 'M16A1': 6}),
  _Inspection('2026년', '재물조사', '2026.06.22', {'K-2': 12, 'K-1A': 8, 'K2C1': 9, 'M16A1': 6}),
];

class _HistoryScreenState extends State<HistoryScreen> {
  String _period = 'q'; // q | y
  int? _sel;

  List<_Inspection> get _list => _period == 'q' ? _quarterly : _yearly;

  Color _typeDot(_Inspection i) => i.isSurvey ? AppColors.gold : AppColors.inspectGray;

  ({String txt, Color color, Color bg}) _delta(int d) {
    if (d > 0) return (txt: '+$d', color: AppColors.gold, bg: AppColors.gold.withOpacity(0.16));
    if (d < 0) return (txt: '$d', color: AppColors.terracotta, bg: AppColors.terracotta.withOpacity(0.16));
    return (txt: '—', color: AppColors.textSub, bg: const Color(0x0DFFFFFF));
  }

  @override
  Widget build(BuildContext context) {
    final list = _list;
    final bIdx = (_sel ?? list.length - 1).clamp(0, list.length - 1);
    final aIdx = (bIdx - 1).clamp(0, list.length - 1);
    final a = list[aIdx], b = list[bIdx];

    final totalA = _order.fold(0, (s, n) => s + a.counts[n]!);
    final totalB = _order.fold(0, (s, n) => s + b.counts[n]!);

    final shortModels = _order.where((n) => b.counts[n]! < _auth[n]!).toList();
    final shortageNote = shortModels.isEmpty
        ? null
        : '${b.label} ${b.type} 기준 ${shortModels.map((n) => '$n ${_auth[n]! - b.counts[n]!}정').join(', ')} 부족. '
            '직전 검사 대비 ${totalA - totalB}정 감소 — 결손 사유 확인 필요.';

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 108),
                children: [
                  _comparisonCard(a, b, totalA, totalB),
                  if (shortageNote != null) ...[
                    const SizedBox(height: 12),
                    _shortageNote(shortageNote),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 20, 4, 11),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '검사 일지 ', style: T.sans(size: 13, weight: FontWeight.w700, color: AppColors.textSub)),
                      TextSpan(text: '· 탭하여 비교 기준 변경', style: T.sans(size: 13, weight: FontWeight.w500, color: AppColors.textSub)),
                    ])),
                  ),
                  for (int i = 0; i < list.length; i++) ...[
                    _historyCard(list[i], i, bIdx, i == list.length - 1),
                    if (i != list.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('검사 내역', style: T.sans(size: 22, weight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(height: 2),
          Text('검열·재물조사 시점별 수량 대조', style: T.sans(size: 12.5, weight: FontWeight.w500, color: AppColors.textSub)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardAlt,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Row(children: [_periodTab('분기별', 'q'), _periodTab('연도별', 'y')]),
          ),
        ],
      ),
    );
  }

  Widget _periodTab(String label, String value) {
    final active = _period == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _period = value;
          _sel = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.chipActive : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: T.sans(size: 14, weight: active ? FontWeight.w800 : FontWeight.w600, color: active ? AppColors.textPrimary : AppColors.textSub)),
          ),
        ),
      ),
    );
  }

  Widget _comparisonCard(_Inspection a, _Inspection b, int totalA, int totalB) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 컬럼 헤드
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _colHead('이전 기준', a)),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: _colHead('비교 기준', b)),
              ],
            ),
          ),
          for (final n in _order) _compRow(n, a.counts[n]!, b.counts[n]!),
          _totalRow(totalA, totalB),
        ],
      ),
    );
  }

  Widget _colHead(String tag, _Inspection ins) {
    return Container(
      color: const Color(0xFF242325),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: T.sans(size: 11.5, weight: FontWeight.w500, color: AppColors.textSub)),
          const SizedBox(height: 3),
          Text(ins.label, style: T.sans(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: _typeDot(ins), shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Flexible(child: Text(ins.type, overflow: TextOverflow.ellipsis, style: T.sans(size: 11.5, weight: FontWeight.w600, color: _typeDot(ins)))),
          ]),
        ],
      ),
    );
  }

  Widget _compRow(String name, int a, int b) {
    final d = _delta(b - a);
    final auth = _auth[name]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderSoft))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: T.mono(size: 15, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('편제 $auth정', style: T.sans(size: 11.5, weight: FontWeight.w500, color: AppColors.textSub)),
              ],
            ),
          ),
          SizedBox(width: 26, child: Text('$a', textAlign: TextAlign.right, style: T.mono(size: 17, weight: FontWeight.w600, color: AppColors.textSub))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 9), child: Icon(Icons.arrow_forward, size: 14, color: AppColors.faint)),
          SizedBox(width: 26, child: Text('$b', style: T.mono(size: 17, weight: FontWeight.w700, color: b < auth ? AppColors.terracotta : AppColors.textPrimary))),
          const SizedBox(width: 8),
          SizedBox(width: 58, child: Align(alignment: Alignment.centerRight, child: _deltaBadge(d))),
        ],
      ),
    );
  }

  Widget _totalRow(int a, int b) {
    final d = _delta(b - a);
    return Container(
      color: const Color(0xFF242325),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text('합계', style: T.sans(size: 14, weight: FontWeight.w800))),
          SizedBox(width: 26, child: Text('$a', textAlign: TextAlign.right, style: T.mono(size: 17, weight: FontWeight.w600, color: AppColors.textSub))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 9), child: Icon(Icons.arrow_forward, size: 14, color: AppColors.faint)),
          SizedBox(width: 26, child: Text('$b', style: T.mono(size: 17, weight: FontWeight.w800))),
          const SizedBox(width: 8),
          SizedBox(width: 58, child: Align(alignment: Alignment.centerRight, child: _deltaBadge(d))),
        ],
      ),
    );
  }

  Widget _deltaBadge(({String txt, Color color, Color bg}) d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: d.bg, borderRadius: BorderRadius.circular(7)),
      child: Text(d.txt, style: T.mono(size: 12.5, weight: FontWeight.w700, color: d.color)),
    );
  }

  Widget _shortageNote(String note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withOpacity(0.1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.terracotta.withOpacity(0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.warning_amber_rounded, size: 17, color: AppColors.terracotta),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(note, style: T.sans(size: 12.5, weight: FontWeight.w500, color: const Color(0xFFE8C8A0), height: 1.55))),
        ],
      ),
    );
  }

  Widget _historyCard(_Inspection ins, int i, int bIdx, bool isCurrent) {
    final isB = i == bIdx;
    final total = _order.fold(0, (s, n) => s + ins.counts[n]!);
    final iconBg = ins.isSurvey ? AppColors.gold.withOpacity(0.14) : AppColors.inspectGray.withOpacity(0.14);
    final iconColor = ins.isSurvey ? AppColors.goldLight : AppColors.inspectGray;
    return GestureDetector(
      onTap: () => setState(() => _sel = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: isB ? AppColors.gold.withOpacity(0.08) : AppColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isB ? AppColors.gold.withOpacity(0.4) : AppColors.borderSoft),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(ins.isSurvey ? Icons.assignment_outlined : Icons.shield_outlined, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(ins.label, style: T.sans(size: 15, weight: FontWeight.w700)),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
                          child: Text('최근', style: T.sans(size: 10.5, weight: FontWeight.w700, color: AppColors.goldLight)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text('${ins.type} · ${ins.date}', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: '$total', style: T.mono(size: 18, weight: FontWeight.w700, color: total < 38 ? AppColors.terracotta : AppColors.goldLight)),
                  TextSpan(text: ' / 38', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
                ])),
                const SizedBox(height: 1),
                Text('총 보유', style: T.sans(size: 11, weight: FontWeight.w500, color: AppColors.textSub)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

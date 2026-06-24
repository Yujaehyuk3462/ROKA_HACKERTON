import 'package:flutter/material.dart';
import '../theme.dart';

/// 기종별 상세 재고 — 검색·필터·기종 카드(탭하여 총번 목록 펼침)
class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _Serial {
  final String no;
  final String state;
  final bool ok;
  final bool pending;
  const _Serial(this.no, this.state, {this.ok = false, this.pending = false});
}

class _Model {
  final String name;
  final String caliber;
  final int qty;
  final int authorized;
  final String lastCheck;
  final List<_Serial> serials;
  const _Model(this.name, this.caliber, this.qty, this.authorized, this.lastCheck, this.serials);

  bool get isShort => qty < authorized;
}

const _data = <_Model>[
  _Model('K-2', '5.56mm 보통탄 · 화기류', 12, 14, '06.22', [
    _Serial('K2-2231140', '양호', ok: true),
    _Serial('K2-2231141', '양호', ok: true),
    _Serial('K2-2231142', '정비요'),
    _Serial('K2-2231143', '미점검', pending: true),
  ]),
  _Model('K-1A', '5.56mm 보통탄 · 화기류', 8, 8, '06.21', [
    _Serial('K1A-100742', '양호', ok: true),
    _Serial('K1A-100743', '양호', ok: true),
  ]),
  _Model('K2C1', '5.56mm 보통탄 · 화기류', 9, 10, '06.22', [
    _Serial('K2C1-04412', '양호', ok: true),
    _Serial('K2C1-04413', '정비요'),
  ]),
  _Model('M16A1', '5.56mm 보통탄 · 화기류', 6, 6, '06.20', [
    _Serial('M16A1-77310', '양호', ok: true),
    _Serial('M16A1-77311', '양호', ok: true),
  ]),
];

class _InventoryListScreenState extends State<InventoryListScreen> {
  String _filter = 'all'; // all | short | ok
  final Set<String> _open = {'K-2'};

  List<_Model> get _rows {
    switch (_filter) {
      case 'short':
        return _data.where((m) => m.isShort).toList();
      case 'ok':
        return _data.where((m) => !m.isShort).toList();
      default:
        return _data;
    }
  }

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
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 108),
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _modelCard(_rows[i]),
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
          Text('기종별 재고', style: T.sans(size: 22, weight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(height: 2),
          Text('학습 기종 4종 · 총 38정 보유',
              style: T.sans(size: 12.5, weight: FontWeight.w500, color: AppColors.textSub)),
          const SizedBox(height: 14),
          _search(),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip('전체 4', 'all'),
              const SizedBox(width: 8),
              _chip('부족 2', 'short'),
              const SizedBox(width: 8),
              _chip('정수일치 2', 'ok'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _search() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 17, color: AppColors.textMute),
          const SizedBox(width: 9),
          Text('기종 · 총번 검색', style: T.sans(size: 14, weight: FontWeight.w500, color: AppColors.textMute)),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final active = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.gold.withOpacity(0.16) : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppColors.gold : AppColors.border),
        ),
        child: Text(label,
            style: T.sans(size: 13, weight: FontWeight.w700, color: active ? AppColors.goldLight : AppColors.textSub)),
      ),
    );
  }

  Widget _modelCard(_Model m) {
    final isOpen = _open.contains(m.name);
    final statusColor = m.isShort ? AppColors.terracotta : AppColors.gold;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 요약 행
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => isOpen ? _open.remove(m.name) : _open.add(m.name)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.inner,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSoft),
                    ),
                    child: const Icon(Icons.gps_fixed, size: 22, color: AppColors.goldLight),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.name, style: T.mono(size: 16.5, weight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(m.isShort ? '부족 ${m.authorized - m.qty}' : '정수일치',
                                  style: T.sans(size: 11, weight: FontWeight.w700, color: statusColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(m.caliber, style: T.sans(size: 12.5, weight: FontWeight.w500, color: AppColors.textSub)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '${m.qty}',
                            style: T.mono(size: 21, weight: FontWeight.w700, color: m.isShort ? AppColors.terracotta : AppColors.textPrimary)),
                        TextSpan(text: ' / ${m.authorized}', style: T.mono(size: 13, weight: FontWeight.w400, color: AppColors.textSub)),
                      ])),
                      const SizedBox(height: 1),
                      Text('보유 / 편제', style: T.sans(size: 11, weight: FontWeight.w500, color: AppColors.textSub)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textSub),
                  ),
                ],
              ),
            ),
          ),
          // 총번 목록
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
              child: Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderSoft))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 2, 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('총번 목록', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
                          Text('최종 점검 ${m.lastCheck}', style: T.sans(size: 11.5, weight: FontWeight.w500, color: AppColors.textSub)),
                        ],
                      ),
                    ),
                    ...m.serials.map(_serialRow),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _serialRow(_Serial s) {
    final color = s.ok ? AppColors.gold : (s.pending ? AppColors.textSub : AppColors.terracotta);
    final dot = s.ok ? AppColors.gold : (s.pending ? AppColors.textMute : AppColors.terracotta);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.serialRow, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(s.no, style: T.mono(size: 13.5, weight: FontWeight.w500))),
          Text(s.state, style: T.sans(size: 12, weight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

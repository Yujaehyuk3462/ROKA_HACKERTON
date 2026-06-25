import 'package:flutter/material.dart';
import '../theme.dart';
import 'capture_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 108),
          children: [
            _header(),
            _primaryCta(context),
            _lowStock(),
            _byModel(),
          ],
        ),
      ),
    );
  }

  // ── 헤더 ──────────────────────────────────────────────
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('행정보급관님', style: T.sans(size: 23, weight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(height: 4),
          Text('제0000부대 · 정기재물조사 진행중',
              style: T.sans(size: 13, weight: FontWeight.w500, color: AppColors.textSub)),
          const SizedBox(height: 18),
          _datePill(),
          const SizedBox(height: 18),
          _statTiles(),
        ],
      ),
    );
  }

  Widget _datePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x38000000),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.goldLight),
          const SizedBox(width: 9),
          Text('2026. 06. 22 (일)', style: T.mono(size: 13.5, weight: FontWeight.w600)),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSub),
        ],
      ),
    );
  }

  Widget _statTiles() {
    return Row(
      children: [
        _tile('3', '총 기종'),
        const SizedBox(width: 8),
        _tile('1', '점검 완료', accent: AppColors.gold, bg: AppColors.gold.withOpacity(0.16)),
        const SizedBox(width: 8),
        _tile('2', '미점검'),
        const SizedBox(width: 8),
        _tile('2', '부족 기종', accent: AppColors.red, bg: AppColors.red.withOpacity(0.16)),
      ],
    );
  }

  Widget _tile(String value, String label, {Color? accent, Color? bg}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        decoration: BoxDecoration(
          color: bg ?? const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent?.withOpacity(0.3) ?? const Color(0x12FFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: T.mono(size: 24, weight: FontWeight.w700, color: accent ?? AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(label, style: T.sans(size: 11.5, weight: FontWeight.w500, color: AppColors.textSub)),
          ],
        ),
      ),
    );
  }

  // ── 주요 CTA ─────────────────────────────────────────
  Widget _primaryCta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CaptureScreen(), fullscreenDialog: true),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.gold.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x29121009),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.photo_camera_outlined, size: 22, color: Color(0xFF2A2310)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('사진으로 재고 등록',
                        style: T.sans(size: 16, weight: FontWeight.w800, color: const Color(0xFF2A2310))),
                    const SizedBox(height: 2),
                    Text('촬영 → 자동 인식 → 수량 입력',
                        style: T.sans(size: 12.5, weight: FontWeight.w600, color: const Color(0x992A2310))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF2A2310)),
            ],
          ),
        ),
      ),
    );
  }

  // ── 부족 재고 ────────────────────────────────────────
  Widget _lowStock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('부족 재고', style: T.sans(size: 16.5, weight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Text('2', style: T.mono(size: 14, weight: FontWeight.w700, color: AppColors.terracotta)),
                  ],
                ),
                Text('전체보기', style: T.sans(size: 13, weight: FontWeight.w500, color: AppColors.textSub)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              children: [
                _lowRow('K-2 소총', '화기류 · 편제 14정', 12, '정', divider: true),
                _lowRow('K2C1 소총', '화기류 · 편제 10정', 9, '정'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lowRow(String name, String sub, int qty, String unit, {bool divider = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: divider ? const Border(bottom: BorderSide(color: Color(0x0DFFFFFF))) : null,
      ),
      child: Row(
        children: [
          Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: T.sans(size: 15, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(sub, style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
              ],
            ),
          ),
          Text.rich(TextSpan(children: [
            TextSpan(text: '$qty', style: T.mono(size: 18, weight: FontWeight.w700, color: AppColors.terracotta)),
            TextSpan(text: ' $unit', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
          ])),
        ],
      ),
    );
  }

  // ── 기종별 재고 (보유/편제 막대) ─────────────────────
  Widget _byModel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: '기종별 재고 ', style: T.sans(size: 16.5, weight: FontWeight.w800)),
              TextSpan(text: '보유 / 편제', style: T.sans(size: 12.5, weight: FontWeight.w600, color: AppColors.textSub)),
            ])),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              children: [
                _bar('K-2 소총', 12, 14, short: true),
                const SizedBox(height: 16),
                _bar('K-1A 소총', 8, 8),
                const SizedBox(height: 16),
                _bar('K2C1 소총', 9, 10, short: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String name, int qty, int auth, {bool short = false}) {
    final ratio = (qty / auth).clamp(0.0, 1.0);
    final color = short ? AppColors.terracotta : AppColors.gold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: T.sans(size: 14, weight: FontWeight.w600)),
              Text.rich(TextSpan(children: [
                TextSpan(text: '$qty', style: T.mono(size: 14, weight: FontWeight.w700, color: color)),
                TextSpan(text: ' / $auth', style: T.mono(size: 13, weight: FontWeight.w400, color: AppColors.textSub)),
              ])),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: const Color(0x12FFFFFF),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

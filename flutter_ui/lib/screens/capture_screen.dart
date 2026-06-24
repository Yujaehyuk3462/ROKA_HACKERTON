import 'package:flutter/material.dart';
import '../theme.dart';

/// 촬영 → 인식 → 수량 입력 (전체화면). 카메라 뷰파인더 ↔ 등록 폼 상태 전환.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _ModelSpec {
  final int authorized;
  final String serial;
  const _ModelSpec(this.authorized, this.serial);
}

const _models = <String, _ModelSpec>{
  'K-2': _ModelSpec(14, 'K2-2231140'),
  'K-1A': _ModelSpec(8, 'K1A-100742'),
  'K2C1': _ModelSpec(10, 'K2C1-04412'),
  'M16A1': _ModelSpec(6, 'M16A1-77310'),
};

class _CaptureScreenState extends State<CaptureScreen> {
  bool _captured = false;
  String _model = 'K-2';
  int _qty = 12;
  String _condition = 'good'; // good | repair | unusable

  int get _authorized => _models[_model]!.authorized;
  String get _serial => _models[_model]!.serial;
  static const _unit = '정';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _captured ? AppColors.bg : const Color(0xFF1B1B1D),
      body: _captured ? _form() : _viewfinder(),
    );
  }

  // ════════════ 뷰파인더 ════════════
  Widget _viewfinder() {
    return SafeArea(
      child: Column(
        children: [
          // 상단 컨트롤
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _roundBtn(Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.gold.withOpacity(0.28)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('총기 · 재고 점검',
                          style: T.sans(size: 12.5, weight: FontWeight.w700, color: AppColors.goldLightest, letterSpacing: 0.4)),
                    ],
                  ),
                ),
                _roundBtn(Icons.bolt, iconColor: AppColors.terracotta),
              ],
            ),
          ),
          // 뷰파인더 영역
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1C),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // 피사체 힌트
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.crop_free, size: 56, color: AppColors.textMute.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text('[ FRAME SUBJECT ]',
                            style: T.mono(size: 11, color: AppColors.textMute, letterSpacing: 1.3)),
                      ],
                    ),
                  ),
                  // 코너 브래킷
                  ..._corners(),
                  // 하단 힌트
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 22,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xA612121A),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text('품목을 프레임 안에 맞추고 촬영하세요',
                            style: T.sans(size: 12.5, weight: FontWeight.w500, color: AppColors.textSoft)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 셔터 행
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 24, 36, 42),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(color: AppColors.inner, borderRadius: BorderRadius.circular(11), border: Border.all(color: AppColors.border)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _captured = true),
                  child: Container(
                    width: 78, height: 78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: 62, height: 62,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.35), blurRadius: 18)],
                        ),
                      ),
                    ),
                  ),
                ),
                _roundBtn(Icons.cameraswitch_outlined, iconColor: AppColors.textSub),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const len = 34.0;
    Widget c({double? top, double? left, double? right, double? bottom, required bool t, required bool l}) {
      return Positioned(
        top: top, left: left, right: right, bottom: bottom,
        child: Container(
          width: len, height: len,
          decoration: BoxDecoration(
            border: Border(
              top: t ? const BorderSide(color: AppColors.gold, width: 2.5) : BorderSide.none,
              bottom: !t ? const BorderSide(color: AppColors.gold, width: 2.5) : BorderSide.none,
              left: l ? const BorderSide(color: AppColors.gold, width: 2.5) : BorderSide.none,
              right: !l ? const BorderSide(color: AppColors.gold, width: 2.5) : BorderSide.none,
            ),
          ),
        ),
      );
    }
    return [
      c(top: 18, left: 18, t: true, l: true),
      c(top: 18, right: 18, t: true, l: false),
      c(bottom: 18, left: 18, t: false, l: true),
      c(bottom: 18, right: 18, t: false, l: false),
    ];
  }

  Widget _roundBtn(IconData icon, {VoidCallback? onTap, Color iconColor = AppColors.textPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0x17FFFFFF)),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }

  // ════════════ 등록 폼 ════════════
  Widget _form() {
    final shortage = _authorized - _qty;
    late String statusLabel;
    late Color statusColor;
    if (shortage > 0) {
      statusLabel = '부족 $shortage$_unit';
      statusColor = AppColors.terracotta;
    } else if (shortage < 0) {
      statusLabel = '초과 ${-shortage}$_unit';
      statusColor = AppColors.red;
    } else {
      statusLabel = '편제 일치';
      statusColor = AppColors.gold;
    }

    return Column(
      children: [
        // 헤더
        Container(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderSoft))),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                _smallBtn(Icons.arrow_back_ios_new_rounded, () => setState(() => _captured = false)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('재고 등록', style: T.sans(size: 18, weight: FontWeight.w800, letterSpacing: -0.2)),
                      const SizedBox(height: 1),
                      Text('정기재물조사 · 진행 12 / 30 품목',
                          style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
                    ],
                  ),
                ),
                _smallBtn(Icons.close_rounded, () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
        // 스크롤 본문
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              _segmented(),
              const SizedBox(height: 13),
              _photoCard(),
              const SizedBox(height: 13),
              _recognizedCard(),
              const SizedBox(height: 13),
              _modelSelector(),
              const SizedBox(height: 13),
              _serialCard(),
              const SizedBox(height: 13),
              _quantityCard(statusLabel, statusColor),
              const SizedBox(height: 13),
              _conditionRow(),
              const SizedBox(height: 13),
              _noteRow(),
            ],
          ),
        ),
        // 저장 CTA (레드)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderSoft))),
          child: GestureDetector(
            onTap: _showSaved,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: AppColors.red.withOpacity(0.32), blurRadius: 18, offset: const Offset(0, 4))],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, size: 20, color: Colors.white),
                    const SizedBox(width: 9),
                    Text('재고 저장', style: T.sans(size: 16.5, weight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: const Color(0x0FFFFFFF), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: AppColors.textSoft),
      ),
    );
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.chipActive, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('총기류', style: T.sans(size: 14.5, weight: FontWeight.w800))),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text('치장물자 · 준비중', style: T.sans(size: 14.5, weight: FontWeight.w600, color: AppColors.faint)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoCard() {
    return Container(
      height: 178,
      decoration: BoxDecoration(
        color: AppColors.inner,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Center(child: Text('[ 촬영 이미지 ]', style: T.mono(size: 11, color: AppColors.textMute, letterSpacing: 1.1))),
          Positioned(
            top: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xB312121A), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('AI 인식됨', style: T.sans(size: 11, weight: FontWeight.w700, color: AppColors.goldLightest)),
              ]),
            ),
          ),
          Positioned(
            top: 12, right: 12,
            child: GestureDetector(
              onTap: () => setState(() => _captured = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xB312121A), borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.refresh_rounded, size: 12, color: AppColors.textPrimary),
                  const SizedBox(width: 5),
                  Text('재촬영', style: T.sans(size: 11, weight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 11, left: 12,
            child: Text('2026.06.22  09:41', style: T.mono(size: 10.5, color: const Color(0x8CFFFFFF))),
          ),
        ],
      ),
    );
  }

  Widget _recognizedCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('인식된 품명', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
                    const SizedBox(height: 3),
                    Text(_model, style: T.sans(size: 21, weight: FontWeight.w800, letterSpacing: -0.2)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red.withOpacity(0.4)),
                ),
                child: Text('총기', style: T.sans(size: 12, weight: FontWeight.w800, color: AppColors.terracotta, letterSpacing: 0.3)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: const LinearProgressIndicator(
                    value: 0.96, minHeight: 5,
                    backgroundColor: Color(0x14FFFFFF),
                    valueColor: AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('신뢰도 96%', style: T.mono(size: 12, weight: FontWeight.w600, color: AppColors.goldLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modelSelector() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('인식 기종 (탭하여 수정)', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
              Text('학습 기종 4종', style: T.sans(size: 11, weight: FontWeight.w700, color: AppColors.textSub)),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              for (final name in _models.keys) ...[
                _modelChip(name),
                if (name != _models.keys.last) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _modelChip(String name) {
    final active = _model == name;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _model = name;
          _qty = _authorized; // 기종 변경 시 현재고를 편제 정수로 초기화
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.gold.withOpacity(0.16) : AppColors.cardAlt,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: active ? AppColors.gold : AppColors.chipActive),
          ),
          child: Center(
            child: Text(name, style: T.mono(size: 13.5, weight: FontWeight.w700, color: active ? AppColors.goldLight : AppColors.textSub)),
          ),
        ),
      ),
    );
  }

  Widget _serialCard() {
    return _panel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('총번 (Serial No.)', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
                const SizedBox(height: 5),
                Text(_serial, style: T.mono(size: 18, weight: FontWeight.w600, letterSpacing: 0.7)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(color: const Color(0x0FFFFFFF), borderRadius: BorderRadius.circular(9)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.edit_outlined, size: 13, color: AppColors.textSoft),
              const SizedBox(width: 5),
              Text('수정', style: T.sans(size: 13, weight: FontWeight.w600, color: AppColors.textSoft)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _quantityCard(String statusLabel, Color statusColor) {
    return _panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('현재고 수량 입력', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
          const SizedBox(height: 14),
          Row(
            children: [
              _stepBtn(false),
              Expanded(
                child: Center(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(text: '$_qty', style: T.mono(size: 46, weight: FontWeight.w700, letterSpacing: -1)),
                    TextSpan(text: ' $_unit', style: T.sans(size: 18, weight: FontWeight.w600, color: AppColors.textSub)),
                  ])),
                ),
              ),
              _stepBtn(true),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderSoft))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: '편제 정수  ', style: T.sans(size: 13, weight: FontWeight.w500, color: AppColors.textSub)),
                  TextSpan(text: '$_authorized', style: T.mono(size: 16, weight: FontWeight.w600)),
                  TextSpan(text: ' $_unit', style: T.sans(size: 13, weight: FontWeight.w500, color: AppColors.textSub)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.16), borderRadius: BorderRadius.circular(999)),
                  child: Text(statusLabel, style: T.sans(size: 13, weight: FontWeight.w700, color: statusColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(bool plus) {
    return GestureDetector(
      onTap: () => setState(() => _qty = plus ? _qty + 1 : (_qty - 1).clamp(0, 999)),
      child: Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          color: plus ? AppColors.gold : AppColors.chipActive,
          borderRadius: BorderRadius.circular(14),
          border: plus ? null : Border.all(color: AppColors.border),
          boxShadow: plus ? [BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 2))] : null,
        ),
        child: Icon(plus ? Icons.add_rounded : Icons.remove_rounded, size: 22, color: plus ? const Color(0xFF2A2310) : AppColors.textPrimary),
      ),
    );
  }

  Widget _conditionRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 9),
          child: Text('상태 판정', style: T.sans(size: 12, weight: FontWeight.w500, color: AppColors.textSub)),
        ),
        Row(
          children: [
            _condChip('good', '양호', AppColors.gold),
            const SizedBox(width: 9),
            _condChip('repair', '정비요', AppColors.terracotta),
            const SizedBox(width: 9),
            _condChip('unusable', '불용', AppColors.red),
          ],
        ),
      ],
    );
  }

  Widget _condChip(String value, String label, Color color) {
    final active = _condition == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _condition = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.14) : AppColors.cardAlt,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: active ? color : AppColors.chipActive),
          ),
          child: Center(
            child: Text(label, style: T.sans(size: 14.5, weight: FontWeight.w700, color: active ? color : AppColors.textSub)),
          ),
        ),
      ),
    );
  }

  Widget _noteRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 16, color: AppColors.textMute),
          const SizedBox(width: 10),
          Text('비고 입력 (탄약고 위치, 결손 사유 등)', style: T.sans(size: 14, weight: FontWeight.w500, color: AppColors.textMute)),
        ],
      ),
    );
  }

  Widget _panel({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: child,
    );
  }

  // ════════════ 저장 완료 다이얼로그 ════════════
  void _showSaved() {
    showDialog(
      context: context,
      barrierColor: const Color(0xC70E0E10),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                ),
                child: const Icon(Icons.check_rounded, size: 32, color: AppColors.goldLight),
              ),
              const SizedBox(height: 18),
              Text('저장 완료', style: T.sans(size: 21, weight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('$_model · $_qty$_unit\n재물조사 대장에 기록되었습니다',
                  textAlign: TextAlign.center,
                  style: T.sans(size: 14, weight: FontWeight.w500, color: AppColors.textSub, height: 1.5)),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _captured = false);
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text('다음 품목 촬영', style: T.sans(size: 15.5, weight: FontWeight.w800, color: const Color(0xFF2A2310)))),
                ),
              ),
              const SizedBox(height: 9),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(color: const Color(0x0DFFFFFF), borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text('조사 목록 보기', style: T.sans(size: 15, weight: FontWeight.w600, color: AppColors.textSoft))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

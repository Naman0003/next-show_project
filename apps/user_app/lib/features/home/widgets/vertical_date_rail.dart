import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class VerticalDateRail extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const VerticalDateRail({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<VerticalDateRail> createState() => _VerticalDateRailState();
}

class _VerticalDateRailState extends State<VerticalDateRail>
    with SingleTickerProviderStateMixin {
  static const _railWidth = 54.0;
  static const _blobWidth = 46.0;
  static const _itemH = 58.0;
  static const _gap = 12.0;
  static const _slot = _itemH + _gap;
  static const _maxStretch = 28.0;
  static const _spring =
  SpringDescription(mass: 1, stiffness: 320, damping: 22);

  late final List<DateTime> _days;
  late final AnimationController _blob; // fractional slot position, 0…N-1
  final _scroll = ScrollController();
  late int _target;
  double _prevValue = 0;
  bool _dragging = false;

  int get _count => _days.length;

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _indexOf(DateTime d) {
    final i = _days.indexWhere((x) => _sameDay(x, d));
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _days = List.generate(
        10, (i) => DateTime(now.year, now.month, now.day + i));
    _target = _indexOf(widget.selectedDate);
    _prevValue = _target.toDouble();
    _blob = AnimationController.unbounded(
      vsync: this,
      value: _target.toDouble(),
    );
  }

  @override
  void didUpdateWidget(VerticalDateRail old) {
    super.didUpdateWidget(old);
    final idx = _indexOf(widget.selectedDate);
    if (!_dragging && idx != _target) _snapTo(idx, 0);
  }

  @override
  void dispose() {
    _blob.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _snapTo(int index, double pixelsPerSecond) {
    _target = index;
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _blob.animateTo(index.toDouble(),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut);
    } else {
      _blob.animateWith(SpringSimulation(
        _spring,
        _blob.value,
        index.toDouble(),
        pixelsPerSecond / _slot, // slots per second
      ));
    }
    _scrollIntoView(index);
  }

  void _scrollIntoView(int index) {
    if (!_scroll.hasClients) return;
    final top = index * _slot;
    final bottom = top + _itemH;
    final offset = _scroll.offset;
    final viewport = _scroll.position.viewportDimension;
    double? to;
    if (top < offset) {
      to = top - 8;
    } else if (bottom > offset + viewport) {
      to = bottom - viewport + 8;
    }
    if (to != null) {
      _scroll.animateTo(
        to.clamp(0.0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  double _fractionAt(double y) =>
      ((y - _itemH / 2) / _slot).clamp(0.0, (_count - 1).toDouble());

  void _onTapUp(TapUpDetails d) {
    final i = (d.localPosition.dy / _slot).floor().clamp(0, _count - 1);
    if (i == _target) return;
    HapticFeedback.selectionClick();
    _snapTo(i, 0);
    widget.onDateSelected(_days[i]);
  }

  void _onScrubStart(LongPressStartDetails d) {
    HapticFeedback.lightImpact();
    _blob.stop();
    _dragging = true;
    _prevValue = _blob.value;
    _blob.value = _fractionAt(d.localPosition.dy);
  }

  void _onScrubUpdate(LongPressMoveUpdateDetails d) {
    _blob.value = _fractionAt(d.localPosition.dy);
  }

  void _onScrubEnd(LongPressEndDetails d) {
    _dragging = false;
    final vy = d.velocity.pixelsPerSecond.dy;
    final projected = (_blob.value + (vy / _slot) * 0.12)
        .clamp(0.0, (_count - 1).toDouble());
    final i = projected.round();
    _snapTo(i, vy);
    if (i != _indexOf(widget.selectedDate)) {
      HapticFeedback.selectionClick();
      widget.onDateSelected(_days[i]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('MMM', 'de_DE').format(widget.selectedDate);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final totalHeight = _count * _slot - _gap;

    return Container(
      width: _railWidth,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              monthStr.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.only(bottom: AppTokens.dockClearance(context)),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: _onTapUp,
                onLongPressStart: _onScrubStart,
                onLongPressMoveUpdate: _onScrubUpdate,
                onLongPressEnd: _onScrubEnd,
                child: SizedBox(
                  width: _railWidth,
                  height: totalHeight,
                  child: AnimatedBuilder(
                    animation: _blob,
                    builder: (context, _) {
                      final p = _blob.value;
                      final frameV = p - _prevValue;
                      _prevValue = p;
                      final stretch = reduced
                          ? 0.0
                          : (frameV.abs() * _slot * 2.2)
                          .clamp(0.0, _maxStretch);
                      final movingUp = frameV < 0;
                      final blobTop =
                          p * _slot - (movingUp ? stretch : 0);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // The single sliding pill
                          Positioned(
                            top: blobTop,
                            left: (_railWidth - _blobWidth) / 2,
                            child: Container(
                              width: _blobWidth,
                              height: _itemH + stretch,
                              decoration: BoxDecoration(
                                color: AppColors.darkPrimary,
                                borderRadius:
                                BorderRadius.circular(_blobWidth / 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x29000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // The dates, morphing as the pill passes
                          Column(
                            children: [
                              for (var i = 0; i < _count; i++) ...[
                                _RailItem(
                                  date: _days[i],
                                  height: _itemH,
                                  on: (1 - (i - p).abs()).clamp(0.0, 1.0),
                                ),
                                if (i < _count - 1)
                                  const SizedBox(height: _gap),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.date,
    required this.height,
    required this.on,
  });

  final DateTime date;
  final double height;
  final double on; // 1 = pill centred here, 0 = a slot or more away

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeIn.transform(on);
    final dayNum = DateFormat('d').format(date);
    final weekday = DateFormat('E', 'de_DE').format(date);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: Transform.scale(
          scale: 1 + 0.07 * on,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dayNum,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: Color.lerp(AppColors.textPrimary, Colors.white, t),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color.lerp(
                      AppColors.textMuted, Colors.white70, t),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
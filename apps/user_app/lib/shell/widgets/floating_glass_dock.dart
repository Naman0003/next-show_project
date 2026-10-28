import 'package:flutter/material.dart' show Icons, Colors;
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

import '../../features/discovery/presentation/theme/cinema_tokens.dart';
import '../../features/discovery/presentation/theme/nsx_motion.dart';
import '../../features/discovery/presentation/widgets/glass.dart';

typedef _Dest = ({IconData icon, IconData active, String label});

/// The app's main navigation — a floating frosted pill hovering over content.
/// A single amber blob marks the current tab. It is gesture-driven: a
/// horizontal pan across the pill drags the blob 1:1 with the finger, the
/// blob stretches toward its travel direction with velocity, the icons morph
/// state continuously as it passes, and on release it spring-snaps to the
/// nearest tab (carrying fling velocity) and switches. Plain taps still work.
class FloatingGlassDock extends StatefulWidget {
  const FloatingGlassDock({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _dests = <_Dest>[
    (icon: Icons.explore_outlined, active: Icons.explore, label: 'Discover'),
    (icon: Icons.dynamic_feed_outlined, active: Icons.dynamic_feed, label: 'Feed'),
    // Search tab hidden — see SearchRouteData in core/router/app_router.dart.
    // (icon: Icons.search, active: Icons.search, label: 'Search'),
    (icon: Icons.bookmark_border, active: Icons.bookmark, label: 'Watchlist'),
    (icon: Icons.person_outline, active: Icons.person, label: 'Profile'),
  ];

  @override
  State<FloatingGlassDock> createState() => _FloatingGlassDockState();
}

class _FloatingGlassDockState extends State<FloatingGlassDock>
    with SingleTickerProviderStateMixin {
  static const _hPad = 10.0;
  static const _blobSize = 44.0;
  static const _maxStretch = 34.0;
  static const _dockHeight = 52.0;

  /// The blob's fractional slot position, 0…N-1.
  late final AnimationController _blob = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );

  double _slot = 0; // pixel width of one tab, set in LayoutBuilder
  // For per-frame velocity → stretch. Starts at the blob's position so the
  // first frame (e.g. opening on Feed) doesn't read as a jump from slot 0
  // and leave the blob stuck stretched.
  late double _prevValue = _blob.value;
  bool _dragging = false;

  int get _count => FloatingGlassDock._dests.length;

  @override
  void didUpdateWidget(FloatingGlassDock old) {
    super.didUpdateWidget(old);
    if (!_dragging && old.selectedIndex != widget.selectedIndex) {
      _snapTo(widget.selectedIndex.toDouble(), 0);
    }
  }

  @override
  void dispose() {
    _blob.dispose();
    super.dispose();
  }

  void _snapTo(double target, double pixelsPerSecond) {
    if (NsxMotion.reduced(context)) {
      _blob.animateTo(target,
          duration: NsxMotion.fast, curve: NsxMotion.expoOut);
    } else {
      final unitsPerSecond = _slot == 0 ? 0.0 : pixelsPerSecond / _slot;
      _blob.animateWith(
        SpringSimulation(NsxMotion.settle, _blob.value, target, unitsPerSecond),
      );
    }
  }

  double _fractionAt(double localX) =>
      (localX / _slot - 0.5).clamp(0.0, (_count - 1).toDouble());

  void _onDragStart(DragStartDetails d) {
    _blob.stop();
    _dragging = true;
    _prevValue = _blob.value;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_slot == 0) return;
    _blob.value = _fractionAt(d.localPosition.dx);
  }

  void _handleDragEnd(DragEndDetails d) {
    _dragging = false;
    final vx = d.velocity.pixelsPerSecond.dx;
    // Project a little in the fling direction before rounding, so a decisive
    // flick past the halfway point lands on the next tab.
    final projected =
        (_blob.value + (vx / _slot) * 0.12).clamp(0.0, (_count - 1).toDouble());
    final target = projected.round();
    _snapTo(target.toDouble(), vx);
    if (target != widget.selectedIndex) {
      HapticFeedback.selectionClick();
      widget.onDestinationSelected(target);
    }
  }

  void _tap(int i) {
    if (i == widget.selectedIndex) return;
    HapticFeedback.selectionClick();
    _snapTo(i.toDouble(), 0);
    widget.onDestinationSelected(i);
  }

  @override
  Widget build(BuildContext context) {
    const dests = FloatingGlassDock._dests;
    final reduced = NsxMotion.reduced(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            NsxSpace.gutter, 0, NsxSpace.gutter, NsxSpace.x4),
        child: GlassSurface(
          fillColor: const Color(0x40FFFFFF),
          // Pinned to the dock's original light hairline so it doesn't follow
          // the glass token as that changes.
          borderColor: const Color(0x24EDE9E1),
          blurSigma: 22,
          padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 8),
          shadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 40,
              offset: Offset(0, 18),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
          child: LayoutBuilder(
            builder: (context, c) {
              _slot = c.maxWidth / _count;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
                onTapUp: (d) => _tap(_fractionAt(d.localPosition.dx).round()),
                child: SizedBox(
                  height: _dockHeight,
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
                      final movingLeft = frameV < 0;
                      final blobLeft = _slot * (p + 0.5) -
                          _blobSize / 2 -
                          (movingLeft ? stretch : 0);

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: blobLeft,
                            child: Container(
                              width: _blobSize + stretch,
                              height: _blobSize,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(_blobSize / 2),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              for (var i = 0; i < dests.length; i++)
                                SizedBox(
                                  width: _slot,
                                  child: _DockIcon(
                                    dest: dests[i],
                                    // 1 when the blob is centred on this icon,
                                    // 0 a slot or more away.
                                    on: (1 - (i - p).abs()).clamp(0.0, 1.0),
                                    selected: i == widget.selectedIndex,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatelessWidget {
  const _DockIcon({
    required this.dest,
    required this.on,
    required this.selected,
  });

  final _Dest dest;
  final double on;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: dest.label,
      child: Center(
        child: Transform.scale(
          scale: 1 + 0.07 * on,
          child: Icon(
            on > 0.5 ? dest.active : dest.icon,
            size: 22,
            color: Color.lerp(
              Colors.white,
              const Color(0xFF111111),
              Curves.easeIn.transform(on),
            ),
          ),
        ),
      ),
    );
  }
}

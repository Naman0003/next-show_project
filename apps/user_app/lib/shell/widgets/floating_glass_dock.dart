import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

import '../../features/discovery/presentation/theme/cinema_tokens.dart';
import '../../features/discovery/presentation/theme/nsx_motion.dart';
import '../../features/discovery/presentation/widgets/glass.dart';
import '../../features/discovery/presentation/widgets/spring_tap.dart';

typedef _Dest = ({IconData icon, IconData active, String label});

/// The app's main navigation, rebuilt as a floating frosted pill hovering
/// over the content. Replaces `ui_kit`'s `NSBottomNavBar`. A single amber
/// blob springs between slots to mark the current tab.
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
    (icon: Icons.search, active: Icons.search, label: 'Search'),
    (icon: Icons.bookmark_border, active: Icons.bookmark, label: 'Watchlist'),
    (icon: Icons.person_outline, active: Icons.person, label: 'Profile'),
  ];

  @override
  State<FloatingGlassDock> createState() => _FloatingGlassDockState();
}

class _FloatingGlassDockState extends State<FloatingGlassDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blob = AnimationController.unbounded(
    vsync: this,
    value: widget.selectedIndex.toDouble(),
  );

  @override
  void didUpdateWidget(FloatingGlassDock old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      final target = widget.selectedIndex.toDouble();
      if (NsxMotion.reduced(context)) {
        _blob.animateTo(target, duration: NsxMotion.fast);
      } else {
        _blob.animateWith(
          SpringSimulation(NsxMotion.settle, _blob.value, target, 0),
        );
      }
    }
  }

  @override
  void dispose() {
    _blob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const dests = FloatingGlassDock._dests;
    const hPad = 10.0;
    const blob = 44.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            NsxSpace.gutter, 0, NsxSpace.gutter, NsxSpace.x4),
        child: GlassSurface(
          blurSigma: 22,
          padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
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
              final slot = (c.maxWidth - hPad * 2) / dests.length;
              return SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _blob,
                      builder: (context, _) => Positioned(
                        left: hPad + slot * _blob.value + (slot - blob) / 2,
                        child: Container(
                          width: blob,
                          height: blob,
                          decoration: const BoxDecoration(
                            color: NsxColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < dests.length; i++)
                          SizedBox(
                            width: slot,
                            child: _DockItem(
                              dest: dests[i],
                              selected: i == widget.selectedIndex,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onDestinationSelected(i);
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.dest,
    required this.selected,
    required this.onTap,
  });

  final _Dest dest;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SpringTap(
      onTap: onTap,
      child: Semantics(
        button: true,
        selected: selected,
        label: dest.label,
        child: SizedBox(
          height: 52,
          child: Center(
            child: Icon(
              selected ? dest.active : dest.icon,
              size: 22,
              color: selected
                  ? NsxColors.accentInk
                  : NsxColors.bone.withOpacity(0.72),
            ),
          ),
        ),
      ),
    );
  }
}

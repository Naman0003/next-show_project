import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import 'tap_scale_container.dart';

/// Search control that morphs from a 44px circle into a full-width pill.
///
/// It sizes itself to the width its parent allows, so place it where the
/// expanded bar can overlay neighbouring content (e.g. in a [Stack]).
class ExpandableSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ExpandableSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar> {
  static const double _size = 44;
  static const Duration _duration = Duration(milliseconds: 500);
  static const Curve _curve = Curves.easeOut;

  bool _isExpanded = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  // Auto-cycling placeholder suggestions
  static const List<String> _autoSuggestions = [
    'Search for movies...',
    'Search for comedy...',
    'Search for concerts...',
    'Search for free open air...',
    'Search by artist or venue...',
  ];

  int _suggestionIndex = 0;
  Timer? _cyclingTimer;

  @override
  void initState() {
    super.initState();
    _startCyclingHints();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  void _startCyclingHints() {
    _cyclingTimer = Timer.periodic(const Duration(milliseconds: 2400), (timer) {
      if (mounted &&
          _isExpanded &&
          !_isFocused &&
          widget.controller.text.isEmpty) {
        setState(() {
          _suggestionIndex = (_suggestionIndex + 1) % _autoSuggestions.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _cyclingTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
    }

  void _expandBar() {
    setState(() => _isExpanded = true);
    _focusNode.requestFocus();
  }

  void _collapseBar() {
    setState(() => _isExpanded = false);
    _focusNode.unfocus();
    widget.controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;

        return Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: _duration,
            curve: _curve,
            width: _isExpanded ? fullWidth : _size,
            height: _size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(
                color: _isFocused ? AppColors.darkPrimary : Colors.transparent,
                width: _isFocused ? 1.6 : 1.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            // Content is laid out at full width and revealed as the pill
            // grows, so the icon stays put and nothing reflows mid-animation.
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              minWidth: fullWidth,
              maxWidth: fullWidth,
              child: Row(
                children: [
                  // Search icon — same 44px slot in both states
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _isExpanded ? _focusNode.requestFocus : _expandBar,
                    child: const SizedBox(
                      width: _size,
                      height: _size,
                      child: Icon(Icons.search_rounded,
                          color: AppColors.darkPrimary, size: 20),
                    ),
                  ),

                  // Input field / auto-cycling hint
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 1 : 0,
                      duration: _duration,
                      curve: _curve,
                      child: IgnorePointer(
                        ignoring: !_isExpanded,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            if (widget.controller.text.isEmpty && !_isFocused)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(opacity: anim, child: child),
                                child: Text(
                                  _autoSuggestions[_suggestionIndex],
                                  key: ValueKey(_suggestionIndex),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            TextField(
                              controller: widget.controller,
                              focusNode: _focusNode,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                              onChanged: (val) {
                                setState(() {});
                                widget.onChanged(val);
                              },
                              decoration: const InputDecoration(
                                hintText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Close "X" — collapses back to the circle
                  AnimatedOpacity(
                    opacity: _isExpanded ? 1 : 0,
                    duration: _duration,
                    curve: _curve,
                    child: IgnorePointer(
                      ignoring: !_isExpanded,
                      child: TapScaleContainer(
                        onTap: _collapseBar,
                        child: const SizedBox(
                          width: _size,
                          height: _size,
                          child: Icon(Icons.close_rounded,
                              size: 20, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

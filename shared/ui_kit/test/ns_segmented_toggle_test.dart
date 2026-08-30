import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _host({
  required int selected,
  required ValueChanged<int> onChanged,
  List<String> segments = const ['One', 'Two'],
  double width = 300,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: NSSegmentedToggle(
            segments: segments,
            selectedIndex: selected,
            onChanged: onChanged,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tapping a segment reports its index', (tester) async {
    int? picked;
    await tester.pumpWidget(_host(selected: 0, onChanged: (i) => picked = i));

    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();

    expect(picked, 1);
  });

  testWidgets('applies the selected vs unselected label style', (tester) async {
    await tester.pumpWidget(_host(selected: 1, onChanged: (_) {}));
    await tester.pumpAndSettle();

    Color colorOf(String label) {
      final text = tester.widget<Text>(find.text(label));
      // AnimatedDefaultTextStyle resolves onto DefaultTextStyle; read that.
      final ctx = tester.element(find.text(label));
      return (text.style?.color) ?? DefaultTextStyle.of(ctx).style.color!;
    }

    // Selected segment uses snow-white ink, unselected uses secondary grey.
    expect(colorOf('Two'), NSColors.snowWhite);
    expect(colorOf('One'), NSColors.textSecondary);
  });

  testWidgets('renders three segments without overflow', (tester) async {
    await tester.pumpWidget(_host(
      selected: 2,
      onChanged: (_) {},
      segments: const ['A', 'B', 'C'],
    ));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('asserts on fewer than two segments', (tester) async {
    expect(
      () => NSSegmentedToggle(
        segments: const ['Only'],
        selectedIndex: 0,
        onChanged: (_) {},
      ),
      throwsAssertionError,
    );
  });
}

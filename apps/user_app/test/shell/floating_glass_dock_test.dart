import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/shell/widgets/floating_glass_dock.dart';

Widget _host({
  required int selected,
  required ValueChanged<int> onSelected,
  bool reduceMotion = false,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingGlassDock(
              selectedIndex: selected,
              onDestinationSelected: onSelected,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('tap on a tab switches to it', (tester) async {
    int? picked;
    await tester.pumpWidget(_host(selected: 0, onSelected: (i) => picked = i));
    await tester.pumpAndSettle();

    // Profile is index 3 and unselected, so it shows the outline icon.
    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pump();

    expect(picked, 3);
  });

  testWidgets('a horizontal drag snaps to the nearest tab and reports it',
      (tester) async {
    int? picked;
    await tester.pumpWidget(_host(selected: 0, onSelected: (i) => picked = i));
    await tester.pumpAndSettle();

    final dock = tester.getRect(find.byType(FloatingGlassDock));
    // Drag from the left tab roughly two slots to the right.
    await tester.dragFrom(
      Offset(dock.left + 40, dock.center.dy),
      Offset(dock.width * 0.5, 0),
    );
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked, greaterThan(0));
  });

  testWidgets('reduced motion still resolves a drag to a tab', (tester) async {
    int? picked;
    await tester.pumpWidget(_host(
      selected: 0,
      onSelected: (i) => picked = i,
      reduceMotion: true,
    ));
    await tester.pumpAndSettle();

    final dock = tester.getRect(find.byType(FloatingGlassDock));
    await tester.dragFrom(
      Offset(dock.left + 40, dock.center.dy),
      Offset(dock.width * 0.75, 0),
    );
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked, greaterThan(1));
  });
}

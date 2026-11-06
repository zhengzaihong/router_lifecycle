import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_pro/router_lib.dart';

void main() {
  var stackCounter = 0;

  Future<RouterProxy> pumpRouter(
    WidgetTester tester, {
    required Map<String, Widget> pageMap,
    RoutePathCallback? routePathCallback,
    Widget? notFoundPage,
    RouteInformationParser<RouteInformation>? parser,
  }) async {
    final stackId = 'p1-test-${stackCounter++}';
    final router = RouterProxy.getDrawerInstance(
      stackId: stackId,
      pageMap: pageMap,
      routePathCallback: routePathCallback,
      notFoundPage: notFoundPage,
      drawerConfig: const DrawerConfig(autoOpen: false, autoClose: false),
    );
    router.clearRouteGuards();
    router.clearPageTypeGuards();
    router.setRouteInformationParser(parser ?? const CustomParser());

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      RouterProxy.removeDrawerInstance(stackId);
    });

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: router,
        routeInformationParser: router.defaultParser(),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  test('normalizeRoutePath handles query-free paths and trailing slashes', () {
    expect(normalizeRoutePath('/profile'), '/profile');
    expect(normalizeRoutePath('/profile/'), '/profile');
    expect(normalizeRoutePath('//profile//settings//'), '/profile/settings');
    expect(normalizeRoutePath(''), '/');
    expect(normalizeRoutePath('/'), '/');
  });

  test('RoutePattern escapes regex metacharacters in templates', () {
    final filePattern = RoutePattern('/file/:name.json');

    expect(filePattern.match('/file/a.json'), {'name': 'a'});
    expect(filePattern.match('/file/axjson'), isNull);
    expect(filePattern.match('/file/aXjson'), isNull);

    final userPattern = RoutePattern('/user/:id');
    expect(userPattern.match('/user/123'), {'id': '123'});
    expect(userPattern.match('/user/123/extra'), isNull);
  });

  test('RouteParams.fromState tolerates dynamic maps and invalid input', () {
    final params = RouteParams.fromState({
      'path': '/user/1',
      'pathParams': {'id': 1},
      'queryParams': {'q': 'x', 'page': 2},
      'matchedPattern': '/user/:id',
    });

    expect(params, isNotNull);
    expect(params!.pathParams, {'id': '1'});
    expect(params.queryParams, {'q': 'x', 'page': '2'});
    expect(params.matchedPattern, '/user/:id');

    expect(RouteParams.fromState(null), isNull);
    expect(RouteParams.fromState('not-a-map'), isNull);
    expect(RouteParams.fromState(<String, Object?>{}), isNotNull);
  });

  testWidgets('getArguments returns null when the type does not match',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
    );

    await router.push(
      page: const _TextPage('detail'),
      name: '/detail',
      arguments: 42,
    );
    await tester.pumpAndSettle();

    expect(router.getArguments<int>(), 42);
    expect(router.getArguments<String>(), isNull);
  });

  testWidgets('concurrent navigations are serialized', (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {
        '/': const _TextPage('root'),
        '/a': const _TextPage('a'),
        '/b': const _TextPage('b'),
      },
    );

    final gate = Completer<void>();
    router.addRouteGuard((from, to) async {
      await gate.future;
      return true;
    });

    final first = router.pushNamed(name: '/a');
    final second = router.pushNamed(name: '/b');
    gate.complete();
    await tester.pumpAndSettle();
    await Future.wait([first, second]);

    expect(router.getLocation(), '/b');
    expect(router.pages.length, 3);
  });

  testWidgets('invalid route names are rejected without breaking the stack',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
    );

    await router.pushNamed(name: 'http://[::1');
    await tester.pumpAndSettle();

    expect(router.getLocation(), '/');
    expect(router.pages.length, 1);
  });

  testWidgets(
      'visibility callback may call notifyNow without concurrent modification',
      (tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    addTearDown(() {
      VisibilityDetectorController.instance.updateInterval =
          const Duration(milliseconds: 500);
    });

    var calls = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: VisibilityDetector(
            key: const ValueKey('visible-box'),
            onVisibilityChanged: (info) {
              calls++;
              if (calls == 1) {
                VisibilityDetectorController.instance.notifyNow();
              }
            },
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(calls, greaterThanOrEqualTo(1));
  });

  testWidgets('LifeCycle reports onResume for visible content', (tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    addTearDown(() {
      VisibilityDetectorController.instance.updateInterval =
          const Duration(milliseconds: 500);
    });

    var resumes = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: LifeCycle(
            visibilityThreshold: 0.5,
            onResume: () => resumes++,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(resumes, 1);
  });

  test('dispose releases static references and notify is safe', () {
    final stackId = 'p1-dispose-${stackCounter++}';
    final router = RouterProxy.getDrawerInstance(
      stackId: stackId,
      pageMap: {'/': const _TextPage('root')},
    );

    router.dispose();

    expect(() => router.notify(), returnsNormally);
    expect(() => router.dispose(), returnsNormally);
    expect(
      RouterProxy.getAllDrawerInstances().containsKey(stackId),
      isFalse,
    );
  });
}

class _TextPage extends StatelessWidget {
  const _TextPage(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(label)),
    );
  }
}

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
    final stackId = 'p0-test-${stackCounter++}';
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

  testWidgets('pushNamed passes parsed state to the route callback',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
      parser: EnhancedParser(
        patterns: [RoutePattern('/user/:id')],
      ),
      routePathCallback: (info) {
        final params = RouteParams.fromState(info.state);
        if (params?.matchedPattern == '/user/:id') {
          return _TextPage('user-${params!.getPathParam('id')}');
        }
        if (info.uri.path == '/search') {
          return _TextPage('search-${params?.getQueryParam('q')}');
        }
        return null;
      },
    );

    await router.pushNamed(name: '/user/123');
    await tester.pumpAndSettle();
    expect(find.text('user-123'), findsOneWidget);

    await router.pushNamed(name: '/search?q=Flutter');
    await tester.pumpAndSettle();
    expect(find.text('search-Flutter'), findsOneWidget);
  });

  testWidgets('pushNamed resolves route aliases through the shared parser',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
      parser: const EnhancedParser(routeAliases: {'/home': '/'}),
    );

    await router.pushNamed(name: '/home');
    await tester.pumpAndSettle();

    expect(router.getLocation(), '/');
    expect(router.pages.length, 2);
  });

  testWidgets('guards run once and see the pre-navigation location',
      (tester) async {
    final calls = <String>[];
    final router = await pumpRouter(
      tester,
      pageMap: {
        '/': const _TextPage('root'),
        '/detail': const _TextPage('detail'),
      },
    );
    router.addRouteGuard((from, to) async {
      calls.add('${from.uri}->${to.uri}');
      return true;
    });

    await router.pushNamed(name: '/detail');
    await tester.pumpAndSettle();

    expect(calls, ['/->/detail']);
    expect(router.getLocation(), '/detail');
  });

  testWidgets('rejected navigation keeps the previous location',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {
        '/': const _TextPage('root'),
        '/detail': const _TextPage('detail'),
      },
    );
    router.addRouteGuard((from, to) async => false);

    await router.pushNamed(name: '/detail');
    await tester.pumpAndSettle();

    expect(router.getLocation(), '/');
    expect(router.pages.length, 1);
  });

  testWidgets('replace keeps the current page when the guard rejects',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
    );
    router.addRouteGuard((from, to) async => false);

    await router.replace(page: const _TextPage('blocked'), name: '/blocked');
    await tester.pumpAndSettle();

    expect(router.pages.length, 1);
    expect(router.getCurrentMaterialPage().name, '/');
    expect(find.text('root'), findsOneWidget);
    expect(router.getLocation(), '/');
  });

  testWidgets('pushAndRemoveAll keeps the stack when the guard rejects',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {
        '/': const _TextPage('root'),
        '/detail': const _TextPage('detail'),
      },
    );
    await router.pushNamed(name: '/detail');
    await tester.pumpAndSettle();
    router.addPageTypeGuard((from, to) async => false);

    await router.pushAndRemoveAll(
      const _TextPage('blocked'),
      name: '/blocked',
    );
    await tester.pumpAndSettle();

    expect(router.pages.length, 2);
    expect(find.text('detail'), findsOneWidget);
  });

  testWidgets('standard mode creates unique page keys', (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
    );

    await router.push(page: const _TextPage('a'), name: '/a');
    await router.push(page: const _TextPage('b'), name: '/b');
    await tester.pumpAndSettle();

    expect(router.pages.length, 3);
    final keys = router.pages.map((page) => page.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  testWidgets('singleTop rebuilds the top page and updates arguments',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
    );

    await router.push(page: const _TextPage('first'), name: '/first');
    await tester.pumpAndSettle();

    await router.push(
      page: const _TextPage('second'),
      name: '/first',
      arguments: 'updated',
      launchMode: LaunchMode.singleTop,
    );
    await tester.pumpAndSettle();

    expect(router.pages.length, 2);
    expect(router.getCurrentMaterialPage().arguments, 'updated');
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('singleInstance removes pages above the existing instance',
      (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
    );

    await router.push(page: const _TextPage('a1'), name: '/a');
    await router.push(page: const _TextPage('b'), name: '/b');
    await router.push(
      page: const _TextPage('a2'),
      name: '/a',
      launchMode: LaunchMode.singleInstance,
    );
    await tester.pumpAndSettle();

    expect(router.pages.length, 2);
    expect(find.text('a2'), findsOneWidget);
    expect(find.text('b'), findsNothing);
  });

  testWidgets('empty page stack falls back instead of throwing',
      (tester) async {
    final router = await pumpRouter(tester, pageMap: const {});
    router.resetForTesting();
    await tester.pumpAndSettle();

    expect(router.pages, isEmpty);
    expect(find.text('你访问的页面不存在'), findsOneWidget);
    expect(router.getCurrentPage(), isA<EmptyPage>());
    expect(router.getCurrentMaterialPage(), isNotNull);
  });

  testWidgets('setNewRoutePath pops back to an existing page', (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {
        '/': const _TextPage('root'),
        '/detail': const _TextPage('detail'),
      },
    );
    await router.pushNamed(name: '/detail');
    await tester.pumpAndSettle();
    expect(router.pages.length, 2);

    await router.setNewRoutePath(RouteInformation(uri: Uri.parse('/')));
    await tester.pumpAndSettle();

    expect(router.pages.length, 1);
    expect(find.text('root'), findsOneWidget);
    expect(router.getLocation(), '/');
  });

  testWidgets('unknown named route uses notFoundPage', (tester) async {
    final router = await pumpRouter(
      tester,
      pageMap: {'/': const _TextPage('root')},
      notFoundPage: const _TextPage('not-found'),
    );

    await router.pushNamed(name: '/missing');
    await tester.pumpAndSettle();

    expect(find.text('not-found'), findsOneWidget);
    expect(router.getLocation(), '/missing');
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

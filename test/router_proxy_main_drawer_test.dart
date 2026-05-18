import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_pro/router_lib.dart';

void main() {
  testWidgets('main drawer control auto-binds the current scaffold',
      (WidgetTester tester) async {
    final rootScaffoldKey = GlobalKey<ScaffoldState>();
    final detailScaffoldKey = GlobalKey<ScaffoldState>();
    final router = RouterProxy.getInstance(
      pageMap: {
        '/': _DrawerHostPage(scaffoldKey: rootScaffoldKey),
      },
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: router,
        routeInformationParser: router.defaultParser(),
      ),
    );
    await tester.pumpAndSettle();

    expect(rootScaffoldKey.currentState?.isDrawerOpen, isFalse);
    expect(router.isMainDrawerOpen(), isFalse);

    router.openMainDrawer();
    await tester.pumpAndSettle();

    expect(rootScaffoldKey.currentState?.isDrawerOpen, isTrue);
    expect(router.isMainDrawerOpen(), isTrue);

    router.closeMainDrawer();
    await tester.pumpAndSettle();

    expect(rootScaffoldKey.currentState?.isDrawerOpen, isFalse);
    expect(router.isMainDrawerOpen(), isFalse);

    await router.push(
      page: _DrawerHostPage(scaffoldKey: detailScaffoldKey),
      name: '/detail',
    );
    await tester.pumpAndSettle();

    router.openMainDrawer();
    await tester.pumpAndSettle();

    expect(detailScaffoldKey.currentState?.isDrawerOpen, isTrue);
    expect(rootScaffoldKey.currentState?.isDrawerOpen, isFalse);
    expect(router.isMainDrawerOpen(), isTrue);

    router.closeMainDrawer();
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    router.openMainDrawer();
    await tester.pumpAndSettle();

    expect(rootScaffoldKey.currentState?.isDrawerOpen, isTrue);
    expect(detailScaffoldKey.currentState, isNull);
  });

  testWidgets('popRoute updates the declarative page stack immediately',
      (WidgetTester tester) async {
    final router = await _pumpRouter(tester);

    await router.push(
      page: const _RouteHostPage(label: 'detail'),
      name: '/detail',
    );
    await tester.pumpAndSettle();

    expect(find.text('detail'), findsOneWidget);
    expect(router.getCurrentMaterialPage().name, '/detail');

    final didPop = await router.popRoute();

    expect(didPop, isTrue);
    expect(router.getCurrentMaterialPage().name, '/');

    await tester.pumpAndSettle();
    expect(find.text('root'), findsOneWidget);
    expect(find.text('detail'), findsNothing);
  });

  testWidgets('popRoute dismisses pageless routes before page routes',
      (WidgetTester tester) async {
    final router = await _pumpRouter(tester);

    await router.push(
      page: const _RouteHostPage(label: 'detail'),
      name: '/detail',
    );
    await tester.pumpAndSettle();

    router.showAppDialog<void>(
      builder: (context) => const AlertDialog(
        title: Text('dialog'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('dialog'), findsOneWidget);
    expect(router.getCurrentMaterialPage().name, '/detail');

    final didPop = await router.popRoute();

    expect(didPop, isTrue);
    expect(router.getCurrentMaterialPage().name, '/detail');

    await tester.pumpAndSettle();
    expect(find.text('dialog'), findsNothing);
    expect(find.text('detail'), findsOneWidget);
  });
}

class _DrawerHostPage extends StatelessWidget {
  const _DrawerHostPage({required this.scaffoldKey});

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const Drawer(
        child: SizedBox.shrink(),
      ),
      body: const SizedBox.shrink(),
    );
  }
}

Future<RouterProxy> _pumpRouter(WidgetTester tester) async {
  final router = RouterProxy.getInstance(
    pageMap: {
      '/': const _RouteHostPage(label: 'root'),
    },
  );

  router.clearRouteGuards();
  router.clearPageTypeGuards();
  router.pageMap = {
    '/': const _RouteHostPage(label: 'root'),
  };

  await tester.pumpWidget(
    MaterialApp.router(
      routerDelegate: router,
      routeInformationParser: router.defaultParser(),
    ),
  );
  await tester.pumpAndSettle();

  router.pushNamedAndRemoveAll(name: '/');
  await tester.pumpAndSettle();
  return router;
}

class _RouteHostPage extends StatelessWidget {
  const _RouteHostPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(label),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_pro/router_lib.dart';

void main() {
  var stackCounter = 0;

  String nextStackId() => 'p2-test-${stackCounter++}';

  RouterProxy createDrawer(
    String stackId, {
    Map<String, Widget> pageMap = const {'/': _TextPage('root')},
  }) {
    return RouterProxy.getDrawerInstance(
      stackId: stackId,
      pageMap: pageMap,
      drawerConfig: const DrawerConfig(autoOpen: false, autoClose: false),
    );
  }

  test('RoutePattern supports unicode and repeated parameters', () {
    final unicodePattern = RoutePattern('/用户/:name');
    expect(unicodePattern.match('/用户/张三'), {'name': '张三'});
    expect(unicodePattern.match('/用户/'), isNull);

    final repeatedPattern = RoutePattern('/x/:id/:id');
    expect(repeatedPattern.match('/x/1/2'), {'id': '2'});
  });

  testWidgets('DrawerStackController ignores updates after dispose',
      (tester) async {
    final stackId = nextStackId();
    final router = createDrawer(stackId);
    addTearDown(() => RouterProxy.removeDrawerInstance(stackId));

    final controller = DrawerStackController(
      scaffoldKey: GlobalKey<ScaffoldState>(),
      routerProxy: router,
      config: const DrawerConfig(autoOpen: false, autoClose: false),
    );

    controller.dispose();
    router.notify();
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('disposeRouter releases the underlying router', (tester) async {
    final stackId = nextStackId();
    final router = createDrawer(stackId);

    final controller = DrawerStackController(
      scaffoldKey: GlobalKey<ScaffoldState>(),
      routerProxy: router,
      config: const DrawerConfig(autoOpen: false, autoClose: false),
    );

    controller.dispose(disposeRouter: true);

    expect(
      RouterProxy.getAllDrawerInstances().containsKey(stackId),
      isFalse,
    );
  });

  testWidgets('resetForTesting restores the root page', (tester) async {
    final stackId = nextStackId();
    final router = createDrawer(stackId);
    addTearDown(() => RouterProxy.removeDrawerInstance(stackId));

    await router.push(page: const _TextPage('detail'), name: '/detail');
    expect(router.pages.length, 2);

    router.resetForTesting();

    expect(router.pages.length, 1);
    expect(router.getCurrentMaterialPage().name, '/');
    expect(router.getLocation(), '/');
  });

  test('push after dispose completes with StateError', () async {
    final stackId = nextStackId();
    final router = createDrawer(stackId);
    router.dispose();

    await expectLater(
      router.push(page: const _TextPage('x'), name: '/x'),
      throwsStateError,
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

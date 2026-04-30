import 'package:flutter/material.dart';
import 'package:router_pro/router_lib.dart';
import 'visibility_example.dart';

/// Router Pro 完整示例
/// 包含所有功能演示：
/// 1. 路由启动模式
/// 2. 路由守卫
/// 3. 命名路由值回传
/// 4. 404错误页面
/// 5. 生命周期感知
/// 6. 可见性检测

void main() {
  // 初始化路由
  initRouter();
  runApp(const MyApp());
}

// 全局路由实例
late RouterProxy router;

// 模拟登录状态
bool _isLoggedIn = false;

void initRouter() {
  router = RouterProxy.getInstance(
    pageMap: {
      '/': const HomePage(),
      '/login': const LoginPage(),
      '/profile': const ProfilePage(),
      '/settings': const SettingsPage(),
      '/visibility': const VisibilityExamplePage(),
      '/lazy-image': const LazyImageExample(),
      '/auto-video': const AutoPlayVideoExample(),
      '/exposure': const ExposureTrackingExample(),
    },
    notFoundPage: const NotFoundPage(),
    exitWindowStyle: _confirmExit,
    routePathCallBack: (routeInfo) {
      // 动态路由回调 - 用于处理路径参数
      final path = routeInfo.uri.path;
      
      // 从 state 中获取解析后的参数
      final params = RouteParams.fromState(routeInfo.state);
      
      if (params != null) {
        // /user/:id - 用户详情
        if (params.matchedPattern == '/user/:id') {
          final userId = params.getPathParam('id');
          return UserDetailPage(userId: userId!);
        }
        
        // /product/:category/:id - 商品详情
        if (params.matchedPattern == '/product/:category/:id') {
          final category = params.getPathParam('category');
          final productId = params.getPathParam('id');
          final color = params.getQueryParam('color');
          final size = params.getQueryParam('size');
          return ProductDetailPage(
            category: category!,
            productId: productId!,
            color: color,
            size: size,
          );
        }
        
        // /search?q=keyword&page=1 - 搜索结果
        if (path == '/search') {
          final keyword = params.getQueryParam('q');
          final page = params.getQueryParam('page');
          return SearchResultPage(
            keyword: keyword ?? '',
            page: int.tryParse(page ?? '1') ?? 1,
          );
        }
      }
      
      return null;
    },
  );

  // 添加命名路由守卫 - 用于 pushNamed 方式
  router.addRouteGuard((from, to) async {
    final protectedRoutes = ['/profile'];
    
    if (protectedRoutes.contains(to.uri.toString()) && !_isLoggedIn) {
      debugPrint('路由守卫: 拦截命名路由 ${to.uri}，需要登录');
      router.pushNamed(name: '/login');
      return false;
    }
    return true;
  });

  // 添加页面类型守卫 - 用于 push(page: xxx) 方式
  router.addPageTypeGuard((fromPageType, toPageType) async {
    final protectedPageTypes = [
      VideoPlayerDemoPage,
      ProfileDetailPage,
    ];
    
    if (protectedPageTypes.contains(toPageType) && !_isLoggedIn) {
      debugPrint('页面类型守卫: 拦截页面类型 $toPageType，需要登录');
      // 这里不能直接 push LoginPage，因为会触发循环，所以用 pushNamed
      router.pushNamed(name: '/login');
      return false;
    }
    return true;
  });
}

Future<bool> _confirmExit(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('退出确认'),
      content: const Text('确定要退出应用吗？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('确定'),
        ),
      ],
    ),
  );
  return result ?? true;
}

// 切换登录状态的辅助函数
void toggleLoginStatus() {
  _isLoggedIn = !_isLoggedIn;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 创建增强的路由解析器
    final parser = EnhancedParser(
      enablePathParams: true,
      enableQueryParams: true,
      routeAliases: {
        '/home': '/',
      },
      patterns: [
        RoutePattern('/user/:id'),
        RoutePattern('/product/:category/:id'),
      ],
    );

    return MaterialApp.router(
      title: 'Router Pro - 完整示例',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerDelegate: router,
      routeInformationParser: parser, // 使用增强的解析器
    );
  }
}

// ============ 首页 ============
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 创建抽屉路由实例
  late final RouterProxy drawerRouter;

  @override
  void initState() {
    super.initState();
    
    // 初始化抽屉路由
    drawerRouter = RouterProxy.getDrawerInstance(
      stackId: 'main-drawer',
      pageMap: {
        '/': const DrawerHomePage(),
        '/drawer-settings': const DrawerSettingsPage(),
        '/drawer-profile': const DrawerProfilePage(),
      },
      drawerConfig: const DrawerConfig(
        autoOpen: true,
        autoClose: true,
        isEndDrawer: true,
      ),
    );
  }

  @override
  void dispose() {
    // 不要在这里清理抽屉路由资源，因为 HomePage 可能会被重建
    // 抽屉路由实例会在应用退出时自动清理
    // RouterProxy.removeDrawerInstance('main-drawer');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      debugLabel: 'HomePage',
      onCreate: () => debugPrint('HomePage onCreate'),
      onResume: () => debugPrint('HomePage onResume'),
      onPause: () => debugPrint('HomePage onPause'),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Router Pro 完整示例'),
          centerTitle: true,
          actions: [
            // 登录状态切换按钮
            IconButton(
              icon: Icon(_isLoggedIn ? Icons.logout : Icons.login),
              tooltip: _isLoggedIn ? '退出登录' : '登录',
              onPressed: () {
                setState(() {
                  toggleLoginStatus();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isLoggedIn ? '已登录' : '已退出登录'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        // 添加抽屉路由栈
        endDrawer: SimpleDrawerWidget(
          router: drawerRouter,
          width: 300,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 登录状态显示
            Card(
              color: _isLoggedIn ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isLoggedIn ? Icons.check_circle : Icons.info,
                      color: _isLoggedIn ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isLoggedIn ? '当前状态：已登录' : '当前状态：未登录',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSectionTitle('🚀 路由功能'),
            _buildFeatureCard(
              icon: Icons.layers,
              title: '路由启动模式',
              description: '演示 Standard、SingleTop、SingleInstance 三种模式',
              onTap: () => _showLaunchModeDemo(context),
            ),
            _buildFeatureCard(
              icon: Icons.security,
              title: '路由守卫（命名路由）',
              description: '演示命名路由拦截和权限验证',
              onTap: () => router.pushNamed(name: '/profile'),
            ),
            _buildFeatureCard(
              icon: Icons.shield,
              title: '页面类型守卫',
              description: '演示 push(page: xxx) 方式的路由守卫',
              onTap: () => router.push(page: const ProfileDetailPage()),
            ),
            _buildFeatureCard(
              icon: Icons.swap_calls,
              title: '命名路由值回传',
              description: '演示通过命名路由传递和接收数据',
              onTap: () => _showValueReturnDemo(context),
            ),
            _buildFeatureCard(
              icon: Icons.menu,
              title: '抽屉路由栈',
              description: '演示抽屉内的独立路由栈管理',
              onTap: () {
                // 打开抽屉并跳转到设置页
                drawerRouter.pushNamed(name: '/drawer-settings');
              },
            ),
            _buildFeatureCard(
              icon: Icons.error_outline,
              title: '404错误页面',
              description: '访问不存在的路由',
              onTap: () => router.pushNamed(name: '/not-exist'),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('🔗 路由解析器'),
            _buildFeatureCard(
              icon: Icons.link,
              title: '增强路由解析器',
              description: '演示路径参数、查询参数、路由别名等功能',
              onTap: () => router.push(page: const EnhancedParserDemoPage()),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('⏱ 生命周期功能'),
            _buildFeatureCard(
              icon: Icons.video_library,
              title: '视频播放生命周期',
              description: '演示视频播放的生命周期管理（需要登录）',
              onTap: () => _showVideoLifecycleDemo(context),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('👁 可见性检测'),
            _buildFeatureCard(
              icon: Icons.visibility,
              title: '可见性检测示例',
              description: '演示列表项可见性监控',
              onTap: () => router.pushNamed(name: '/visibility'),
            ),
            _buildFeatureCard(
              icon: Icons.image,
              title: '懒加载图片',
              description: '演示图片懒加载',
              onTap: () => router.pushNamed(name: '/lazy-image'),
            ),
            _buildFeatureCard(
              icon: Icons.play_circle,
              title: '视频自动播放',
              description: '演示视频自动播放/暂停',
              onTap: () => router.pushNamed(name: '/auto-video'),
            ),
            _buildFeatureCard(
              icon: Icons.analytics,
              title: '曝光统计',
              description: '演示商品曝光统计',
              onTap: () => router.pushNamed(name: '/exposure'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLaunchModeDemo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '选择启动模式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.layers),
              title: const Text('Standard 标准模式'),
              subtitle: const Text('可创建多个实例'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: const DetailPage(title: '标准模式'),
                  launchMode: LaunchMode.standard,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.vertical_align_top),
              title: const Text('SingleTop 栈顶复用'),
              subtitle: const Text('栈顶已存在则更新参数（类似Android onNewIntent）'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: DetailPage(title: '栈顶复用 - ${DateTime.now().second}秒'),
                  launchMode: LaunchMode.singleTop,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.filter_1),
              title: const Text('SingleInstance 单例模式'),
              subtitle: const Text('全栈唯一实例，清除上层页面'),
              onTap: () {
                Navigator.pop(context);
                router.push(
                  page: SingleInstanceDemoPage(timestamp: DateTime.now().toString()),
                  launchMode: LaunchMode.singleInstance,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showValueReturnDemo(BuildContext context) {
    router.pushNamed(
      name: '/settings',
      onResult: (value) {
        router.showAppSnackBar(message:value);
      },
    );
  }

  void _showVideoLifecycleDemo(BuildContext context) {
    router.push(page: const VideoPlayerDemoPage());
  }
}

// ============ 详情页 ============
class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                router.push(
                  page: DetailPage(title: '$title - 子页面'),
                );
              },
              child: const Text('继续跳转'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 登录页 ============
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              '请先登录',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // 模拟登录成功
                router.pop();
              },
              icon: const Icon(Icons.login),
              label: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 个人中心 ============
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: const Center(
        child: Text('个人中心页面'),
      ),
    );
  }
}

// ============ 设置页 ============
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 返回时携带数据
            router.pop('设置已保存');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('设置页面'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                router.pop('用户点击了保存按钮');
              },
              child: const Text('保存并返回'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 404页面 ============
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('抱歉，您访问的页面不存在'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => router.goRootPage(),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 视频播放演示页 ============
class VideoPlayerDemoPage extends StatefulWidget {
  const VideoPlayerDemoPage({Key? key}) : super(key: key);

  @override
  State<VideoPlayerDemoPage> createState() => _VideoPlayerDemoPageState();
}

class _VideoPlayerDemoPageState extends State<VideoPlayerDemoPage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      visibilityThreshold: 0.8,
      debugLabel: 'VideoPlayer',
      onResume: () {
        setState(() => _isPlaying = true);
        debugPrint('视频开始播放');
      },
      onPause: () {
        setState(() => _isPlaying = false);
        debugPrint('视频暂停');
      },
      onDestroy: () {
        debugPrint('视频资源释放');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('视频播放生命周期'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => router.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _isPlaying ? Icons.play_circle_filled : Icons.pause_circle_filled,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isPlaying ? '播放中...' : '已暂停',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                '页面80%可见时自动播放\n页面不可见时自动暂停',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ 个人详情页（用于演示页面类型守卫）============
class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              '个人详情页面',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            const Text(
              '此页面通过页面类型守卫保护',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              '使用 router.push(page: ProfileDetailPage()) 跳转',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ SingleInstance 演示页 ============
class SingleInstanceDemoPage extends StatelessWidget {
  final String timestamp;
  
  const SingleInstanceDemoPage({
    Key? key,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SingleInstance 演示'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.filter_1,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'SingleInstance 模式',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '创建时间: $timestamp',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                '特点：',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '• 全局唯一实例\n'
                '• 已存在时更新参数\n'
                '• 清除该页面上面的所有页面\n'
                '• 适用于购物车、首页等场景',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  router.push(page: const IntermediatePage());
                },
                icon: const Icon(Icons.add),
                label: const Text('添加中间页面'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  router.push(
                    page: SingleInstanceDemoPage(
                      timestamp: DateTime.now().toString(),
                    ),
                    launchMode: LaunchMode.singleInstance,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('再次启动（会清除中间页面）'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ 中间页面（用于演示 SingleInstance 清除效果）============
class IntermediatePage extends StatelessWidget {
  const IntermediatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('中间页面'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.layers, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              '这是一个中间页面',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              '当再次启动 SingleInstance 页面时\n这个页面会被清除',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                router.push(page: const IntermediatePage());
              },
              child: const Text('再添加一个中间页面'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                router.push(
                  page: SingleInstanceDemoPage(
                    timestamp: DateTime.now().toString(),
                  ),
                  launchMode: LaunchMode.singleInstance,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('返回 SingleInstance 页面'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 增强路由解析器演示页 ============
class EnhancedParserDemoPage extends StatelessWidget {
  const EnhancedParserDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('增强路由解析器示例'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 提示',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '本示例演示 EnhancedParser 的功能：\n'
                    '• 路径参数解析 (/user/:id)\n'
                    '• 查询参数解析 (?key=value)\n'
                    '• 路由别名 (/home -> /)\n'
                    '• 混合使用',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '路径参数示例',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildExampleCard(
            title: '用户详情',
            description: '路径: /user/:id',
            example: '示例: /user/123',
            onTap: () {
              router.pushNamed(name: '/user/123');
            },
          ),
          _buildExampleCard(
            title: '商品详情',
            description: '路径: /product/:category/:id',
            example: '示例: /product/electronics/456',
            onTap: () {
              router.pushNamed(name: '/product/electronics/456');
            },
          ),
          const SizedBox(height: 20),
          const Text(
            '查询参数示例',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildExampleCard(
            title: '搜索结果',
            description: '路径: /search?q=keyword&page=1',
            example: '示例: /search?q=Flutter&page=2',
            onTap: () {
              router.pushNamed(name: '/search?q=Flutter&page=2');
            },
          ),
          _buildExampleCard(
            title: '商品详情（带查询参数）',
            description: '路径: /product/:category/:id?color=red',
            example: '示例: /product/electronics/456?color=red&size=large',
            onTap: () {
              router.pushNamed(
                name: '/product/electronics/456?color=red&size=large',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required String example,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 2),
            Text(
              example,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ============ 用户详情页（路径参数示例）============
class UserDetailPage extends StatelessWidget {
  final String userId;

  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户详情 #$userId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              '用户 ID: $userId',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            const Text(
              '✅ 路径参数已成功解析',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              '路径: /user/:id',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => router.pop(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ 商品详情页（路径参数 + 查询参数示例）============
class ProductDetailPage extends StatelessWidget {
  final String category;
  final String productId;
  final String? color;
  final String? size;

  const ProductDetailPage({
    Key? key,
    required this.category,
    required this.productId,
    this.color,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品详情 #$productId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                '商品 ID: $productId',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                '分类: $category',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              if (color != null) ...[
                const SizedBox(height: 10),
                Text(
                  '颜色: $color',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
              if (size != null) ...[
                const SizedBox(height: 10),
                Text(
                  '尺寸: $size',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                '✅ 路径参数和查询参数已成功解析',
                style: TextStyle(color: Colors.green, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '路径: /product/:category/:id?color=xxx&size=xxx',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => router.pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ 搜索结果页（查询参数示例）============
class SearchResultPage extends StatelessWidget {
  final String keyword;
  final int page;

  const SearchResultPage({
    Key? key,
    required this.keyword,
    this.page = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('搜索: $keyword'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              '关键词: $keyword',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              '页码: $page',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              '✅ 查询参数已成功解析',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              '路径: /search?q=xxx&page=xxx',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (page > 1)
                  ElevatedButton(
                    onPressed: () {
                      router.pushNamed(
                        name: '/search?q=$keyword&page=${page - 1}',
                      );
                    },
                    child: const Text('上一页'),
                  ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    router.pushNamed(
                      name: '/search?q=$keyword&page=${page + 1}',
                    );
                  },
                  child: const Text('下一页'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ============ 抽屉路由栈页面 ============

/// 抽屉首页
class DrawerHomePage extends StatelessWidget {
  const DrawerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    
    return Column(
      children: [
        // 抽屉头部
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '抽屉路由栈',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => drawerRouter.closeDrawerStack(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '独立的路由栈管理',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 菜单列表
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerTile(
                icon: Icons.settings,
                title: '设置',
                subtitle: '应用设置和偏好',
                onTap: () {
                  drawerRouter.push(page: const DrawerSettingsPage());
                },
              ),
              _buildDrawerTile(
                icon: Icons.person,
                title: '个人资料',
                subtitle: '查看和编辑个人信息',
                onTap: () {
                  drawerRouter.push(page: const DrawerProfilePage());
                },
              ),
              _buildDrawerTile(
                icon: Icons.notifications,
                title: '通知',
                subtitle: '消息和提醒',
                onTap: () {
                  drawerRouter.push(page: const DrawerNotificationPage());
                },
              ),
              const Divider(),
              _buildDrawerTile(
                icon: Icons.info,
                title: '关于',
                subtitle: '应用信息和版本',
                onTap: () {
                  drawerRouter.push(page: const DrawerAboutPage());
                },
              ),
              _buildDrawerTile(
                icon: Icons.help,
                title: '帮助',
                subtitle: '使用指南和常见问题',
                onTap: () {
                  drawerRouter.push(page: const DrawerHelpPage());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// 抽屉设置页
class DrawerSettingsPage extends StatelessWidget {
  const DrawerSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    
    return Column(
      children: [
        AppBar(
          title: const Text('设置'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => drawerRouter.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => drawerRouter.closeDrawerStack(),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: [
              _buildSettingSection(
                title: '通用设置',
                items: [
                  _buildSettingTile(
                    icon: Icons.language,
                    title: '语言',
                    subtitle: '简体中文',
                    onTap: () {
                      drawerRouter.push(page: const DrawerLanguagePage());
                    },
                  ),
                  _buildSettingTile(
                    icon: Icons.palette,
                    title: '主题',
                    subtitle: '跟随系统',
                    onTap: () {
                      drawerRouter.push(page: const DrawerThemePage());
                    },
                  ),
                ],
              ),
              _buildSettingSection(
                title: '隐私设置',
                items: [
                  _buildSettingTile(
                    icon: Icons.lock,
                    title: '隐私',
                    subtitle: '管理隐私选项',
                    onTap: () {
                      drawerRouter.push(page: const DrawerPrivacyPage());
                    },
                  ),
                  _buildSettingTile(
                    icon: Icons.security,
                    title: '安全',
                    subtitle: '密码和安全设置',
                    onTap: () {
                      drawerRouter.push(page: const DrawerSecurityPage());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// 抽屉个人资料页
class DrawerProfilePage extends StatelessWidget {
  const DrawerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    
    return Column(
      children: [
        AppBar(
          title: const Text('个人资料'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => drawerRouter.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                drawerRouter.push(page: const DrawerEditProfilePage());
              },
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '用户名',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'user@example.com',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoCard('手机号', '+86 138 0000 0000'),
              _buildInfoCard('生日', '1990-01-01'),
              _buildInfoCard('地址', '北京市朝阳区'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 其他抽屉子页面（简化实现）
class DrawerNotificationPage extends StatelessWidget {
  const DrawerNotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '通知', Icons.notifications);
  }
}

class DrawerAboutPage extends StatelessWidget {
  const DrawerAboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '关于', Icons.info);
  }
}

class DrawerHelpPage extends StatelessWidget {
  const DrawerHelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '帮助', Icons.help);
  }
}

class DrawerLanguagePage extends StatelessWidget {
  const DrawerLanguagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '语言设置', Icons.language);
  }
}

class DrawerThemePage extends StatelessWidget {
  const DrawerThemePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '主题设置', Icons.palette);
  }
}

class DrawerPrivacyPage extends StatelessWidget {
  const DrawerPrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '隐私设置', Icons.lock);
  }
}

class DrawerSecurityPage extends StatelessWidget {
  const DrawerSecurityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '安全设置', Icons.security);
  }
}

class DrawerEditProfilePage extends StatelessWidget {
  const DrawerEditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final drawerRouter = RouterProxy.getDrawerInstance(stackId: 'main-drawer');
    return _buildSimplePage(drawerRouter, '编辑资料', Icons.edit);
  }
}

Widget _buildSimplePage(RouterProxy router, String title, IconData icon) {
  return Column(
    children: [
      AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => router.pop(),
        ),
      ),
      Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '这是一个示例页面',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

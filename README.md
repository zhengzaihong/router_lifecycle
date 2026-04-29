# 🚀 Router Pro · Routing & Lifecycle Awareness Tools

[![pub package](https://img.shields.io/pub/v/router_pro.svg)](https://pub.dev/packages/router_pro)
[![GitHub stars](https://img.shields.io/github/stars/zhengzaihong/router_lifecycle.svg?style=social)](https://github.com/zhengzaihong/router_lifecycle)
[![license](https://img.shields.io/github/license/zhengzaihong/router_lifecycle)](LICENSE)

Language: English | [简体中文](README-ZH.md)

---

## ✨ Why choose Router Pro?

In Flutter development, pages often need to have life cycle capabilities (`onResume`,`onPause`,`onDestroy`) like Android's **Activity/Fragment** for lazy loading or improved performance experience.  
However, Flutter's **StatelessWidget/StatefulWidget** does not natively support these features.

**Router Pro provides a complete solution:**

- 🔗 **Routing agent**: easier page jumps and rollback
- ⏱ **Life-cycle perception**: Stateless/StatefulWidget changes Activity/Fragment in seconds
- 🚀 **Route launch modes**: Support Standard, SingleTop, SingleInstance modes
- 🛡️ **Route guards**: Support route interception for permission verification
- 🎯 **Named route value return**: Support passing and receiving data through named routes
- 🪶 **Decoupled design**: Routing and life cycle are used independently
- 🌍 **Cross-platform support**: App & Web

---

## 🌟 characteristics are as

- ✅ Flutter pages can also enjoy **Native Life Cycle Awareness**
- ✅ Provide more elegant **route jump/close API**
- ✅ **Decoupled design**: Routing and lifecycle can be used separately
- ✅ Support **Cross-platform (App & Web)**
- ✅ Support **Route Launch Modes** (Standard, SingleTop, SingleInstance)
- ✅ Support **Named Route Value Return**
- ✅ Support **Route Navigation Guards** (Interceptors)
- ✅ Support **Custom 404 Error Page**
- ✅ Use routing without BuildContext dependency

## 📦 install

Add to `pubspec.yaml`:

```yaml
dependencies:
  router_pro: ^0.2.0
```

import:

```dart
import 'package:router_pro/router_lib.dart';
```

---

## ⚡ Function 1: RouterProxy

### global registration

```dart
RouterProxy router = RouterProxy.getInstance(
  pageMap: {'/': const Login()},
  exitWindowStyle: _confirmExit,
  notFoundPage: const NotFoundPage(), // Optional: Custom 404 page
);
```

```dart
MaterialApp.router(
  routerDelegate: router,
  routeInformationParser: router.defaultParser(),
);
```

### page skip

```dart
router.push();  //Jump to page widget method
router.pushNamed(); //Jump page routing path method
router.replace(); //Replace current page
router.popAndPushNamed(); //Pop the current page, then push a new page
router.pushAndRemoveAll();//Empty the page stack and push new page
router.pushNamedAndRemoveAll();// Skip to the specified page and clear all previous pages
router.pushStackTop();//Place the page at the top of the stack (remove it first if it already exists)

//example：
router.push(
  page:const TaoBaoPageDetail(),
  launchMode: LaunchMode.standard, // Optional: Launch mode
  onResult: (value){ //optional
    setState((){
      title = "Taobao page$value";
    });
  });
router.pushNamed(
  name: '/TaoBaoPageDetail',
  launchMode: LaunchMode.singleTop, // Optional: Launch mode
  onResult: (value){ //optional: Support named route value return
    setState((){
      title = "Taobao page$value";
    });
  });
```

### Route Launch Modes

Supports three launch modes, similar to Android Activity launch modes:

```dart
// 1. Standard mode (default) - Allows multiple instances of the same page
router.push(
  page: const DetailPage(),
  launchMode: LaunchMode.standard,
);

// 2. Single Top - If the target page is already at the top of the stack, no new instance is created
router.push(
  page: const DetailPage(),
  launchMode: LaunchMode.singleTop,
);

// 3. Single Instance - Only one instance in the entire stack, moves to top if already exists
router.push(
  page: const DetailPage(),
  launchMode: LaunchMode.singleInstance,
);
```
### Page close & return

```dart
router.pop(); //Close the current page
router.popWithResult(); //Close the current page, mainly used for (dialog, Bottom Sheet..)

example：
router.popWithResult("return value：hello"); //Return value optional
router.pop("return value：hello"); //Return value optional
```

### Pop-up windows without context

```dart
router.showAppBottomSheet()
router.showAppDialog()
router.showAppSnackBar()

example：
router.showAppBottomSheet(builder: (context){
     return  Container(
       height: 400,
       width: MediaQuery.of(context).size.width,
       color: Colors.red,
       child: GestureDetector(
         onTap: (){
           router.popWithResult("This is the return result");
         },
         child: const Text('Click on me to get the return value of Bottom Sheet'),
       ),
     );
   }).then((value){
       debugPrint("showAppBottomSheet value:${value}");
});
```

### Route Navigation Guards

Support route interception for permission verification, login checks, etc.:

```dart
// Add route guard
router.addRouteGuard((from, to) async {
  // Pages that require login
  final protectedRoutes = ['/profile', '/settings'];
  final isLoggedIn = await checkLoginStatus();
  
  if (protectedRoutes.contains(to.uri.toString()) && !isLoggedIn) {
    // Intercept navigation, redirect to login page
    router.pushNamed(name: '/login');
    return false; // Return false to block navigation
  }
  return true; // Return true to allow navigation
});

// Remove route guard
router.removeRouteGuard(guard);

// Clear all route guards
router.clearRouteGuards();
```

### 404 Error Page

Support custom error page for undefined routes:

```dart
RouterProxy router = RouterProxy.getInstance(
  pageMap: {'/': const HomePage()},
  notFoundPage: const Custom404Page(), // Custom 404 page
);

// When accessing a non-existent route, the 404 page will be displayed
router.pushNamed(name: '/not-exist');
```
---

## ⚡ Function 2: Life cycle perception

make **StatelessWidget / StatefulWidget** have `onResume / onPause / onDestroy` ability：

```dart
class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      onCreate: () => print("Login onCreate"),
      onStart: () => print("Login onStart"),
      onResume: () => print("Login onResume"),
      onPause: () => print("Login onPause"),
      onDestroy: () => print("Login onDestroy"),
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => router.push(page: NavPage()),
            child: const Text("Login"),
          ),
        ),
      ),
    );
  }
}
```

### Advanced Features

**Visibility Threshold**: Customize the visibility percentage to trigger onResume

```dart
LifeCycle(
  visibilityThreshold: 0.5, // Trigger onResume at 50% visible, default 1.0 (fully visible)
  onResume: () => print('Page 50% visible'),
  child: YourWidget(),
)
```

**Debug Mode**: Output lifecycle logs

```dart
LifeCycle(
  debugLabel: 'HomePage', // Enable debug logging
  onCreate: () => print('Created'),
  onResume: () => print('Visible'),
  child: YourWidget(),
)
// Output: [LifeCycle:HomePage] onCreate
// Output: [LifeCycle:HomePage] onResume (widget visible: 100.0%)
```

---

## ⚡ Function 3: Visibility Detection

Low-level visibility detection component for precise visibility monitoring.

### Basic Usage

```dart
VisibilityDetector(
  key: Key('my-widget'),
  onVisibilityChanged: (info) {
    print('Visible fraction: ${info.visibleFraction}');
    
    // Use convenience properties
    if (info.isFullyVisible) {
      print('Fully visible');
    } else if (info.isPartiallyVisible) {
      print('Partially visible');
    } else if (info.isInvisible) {
      print('Invisible');
    }
  },
  child: YourWidget(),
)
```

### Use Cases

**1. Lazy Loading Images**

```dart
VisibilityDetector(
  key: Key('image-$index'),
  onVisibilityChanged: (info) {
    if (info.visibleFraction >= 0.5 && !imageLoaded) {
      loadImage(); // Load when 50% visible
    }
  },
  child: Image.network(imageUrl),
)
```

**2. Auto-play Videos**

```dart
VisibilityDetector(
  key: Key('video-$index'),
  onVisibilityChanged: (info) {
    if (info.visibleFraction >= 0.8) {
      videoController.play(); // Play when 80% visible
    } else if (info.isInvisible) {
      videoController.pause(); // Pause when invisible
    }
  },
  child: VideoPlayer(videoController),
)
```

**3. Exposure Tracking**

```dart
VisibilityDetector(
  key: Key('item-$index'),
  onVisibilityChanged: (info) {
    if (info.isFullyVisible) {
      trackExposure(itemId); // Track when fully visible
    }
  },
  child: ProductCard(product),
)
```

**4. List Item Visibility Monitoring**

```dart
ListView.builder(
  itemBuilder: (context, index) {
    return VisibilityDetector(
      key: Key('list-item-$index'),
      onVisibilityChanged: (info) {
        print('Item $index: ${(info.visibleFraction * 100).toInt()}% visible');
      },
      child: ListTile(title: Text('Item $index')),
    );
  },
)
```

### VisibilityInfo Properties

- `visibleFraction`: Visible fraction (0.0 - 1.0)
- `isVisible`: Whether visible (> 0%)
- `isInvisible`: Whether invisible (0%)
- `isFullyVisible`: Whether fully visible (100%)
- `isPartiallyVisible`: Whether partially visible (0% - 100%)
- `size`: Widget size
- `visibleBounds`: Visible bounds

### Controller Configuration

```dart
// Set update interval
VisibilityDetectorController.instance.updateInterval = Duration(milliseconds: 300);

// Trigger all callbacks immediately
VisibilityDetectorController.instance.notifyNow();

// Clear callbacks for specific widget
VisibilityDetectorController.instance.forget(Key('my-widget'));

// Get widget bounds
final bounds = VisibilityDetectorController.instance.widgetBoundsFor(Key('my-widget'));
```



---

## 📖 Usage Examples

### Example 1: Login Guard

```dart
void initRouter() {
  final router = RouterProxy.getInstance(
    pageMap: {'/': HomePage(), '/login': LoginPage(), '/profile': ProfilePage()},
  );

  // Add login verification guard
  router.addRouteGuard((from, to) async {
    final protectedRoutes = ['/profile', '/settings', '/orders'];
    if (protectedRoutes.contains(to.uri.toString())) {
      final isLoggedIn = await checkLoginStatus();
      if (!isLoggedIn) {
        router.pushNamed(name: '/login');
        return false;
      }
    }
    return true;
  });
}
```

### Example 2: Video Player Lifecycle

```dart
class VideoPlayerPage extends StatefulWidget {
  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network('video_url');
  }

  @override
  Widget build(BuildContext context) {
    return LifeCycle(
      visibilityThreshold: 0.8,            // Play when 80% visible
      debugLabel: 'VideoPlayer',           // Debug logging
      onResume: () => _controller.play(),  // Play when visible
      onPause: () => _controller.pause(),  // Pause when invisible
      onDestroy: () => _controller.dispose(), // Release resources
      child: Scaffold(
        body: VideoPlayer(_controller),
      ),
    );
  }
}
```

### Example 3: Shopping Cart Single Instance

```dart
// Shopping cart page maintains only one instance in the entire app
router.push(
  page: const ShoppingCartPage(),
  launchMode: LaunchMode.singleInstance,
);
```

### Example 4: Custom 404 Page

```dart
class NotFoundPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            Text('Sorry, the page you are looking for does not exist'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => router.goRootPage(),
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎬 effect demonstration

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)

---

## 📋 Quick Reference

### Navigation
```dart
router.push(page: MyPage());                                    // Widget navigation
router.pushNamed(name: '/page');                                // Named route navigation
router.push(page: MyPage(), launchMode: LaunchMode.singleTop);  // Single top
router.push(page: MyPage(), launchMode: LaunchMode.singleInstance); // Single instance
```

### Close Routes
```dart
router.pop();                      // Close current page
router.pop('return data');         // Close with data
router.popWithResult('return data'); // For Dialog/BottomSheet
```

### Route Guards
```dart
router.addRouteGuard((from, to) async {
  // Return true to allow, false to block
  return true;
});
```

### Dialogs
```dart
router.showAppDialog(builder: (ctx) => AlertDialog(...));
router.showAppBottomSheet(builder: (ctx) => Container(...));
router.showAppSnackBar(message: 'Message');
```

### Lifecycle
```dart
// Basic usage
LifeCycle(
  onResume: () => print('Page visible'),
  onPause: () => print('Page invisible'),
  onDestroy: () => print('Page destroyed'),
  child: YourWidget(),
)

// Advanced usage
LifeCycle(
  visibilityThreshold: 0.5,  // Trigger at 50% visible
  debugLabel: 'MyPage',      // Debug logging
  onResume: () => print('Visible'),
  child: YourWidget(),
)
```

---

## 🔄 Migration Guide

### Upgrading from 0.1.x to 0.2.0

Version 0.2.0 is **fully backward compatible**. All existing code works without modifications.

**New Features (optional):**
- Route launch modes (`launchMode` parameter)
- Route navigation guards (`addRouteGuard` method)
- Named route value return (`onResult` in `pushNamed`)
- Custom 404 page (`notFoundPage` parameter)

**Upgrade Steps:**
```yaml
# Update pubspec.yaml
dependencies:
  router_pro: ^0.2.0
```

```bash
flutter pub get
```

---

## 📝 Complete Example

See [example/lib/main.dart](example/lib/main.dart) for complete example code, including:
- ✅ All route launch mode demonstrations
- ✅ Named route value return
- ✅ Route guard interception
- ✅ 404 error page
- ✅ Lifecycle awareness
- ✅ Visibility detection use cases

Run example:
```bash
cd example
flutter run
```

---

## 🛠 other explanatory

- `ExitWindowStyle`: Customizable prompt box to exit the program
- Web side: Support browser direct access, need to customize `RouteParser`
- Complete API documentation: See source code comments

---

## 📄 Changelog

### v0.2.0
- ✅ Added route launch modes (Standard, SingleTop, SingleInstance)
- ✅ Added route navigation guards
- ✅ Added named route value return support
- ✅ Added custom 404 error page
- ✅ Added lifecycle visibility threshold (visibilityThreshold)
- ✅ Added lifecycle debug mode (debugLabel)
- ✅ Added VisibilityInfo convenience properties (isVisible, isInvisible, isFullyVisible, isPartiallyVisible)
- ✅ Optimized route stack management
- ✅ Improved visibility detection logic
- ✅ Enhanced documentation with complete examples

### v0.1.1
- Router proxy functionality
- Lifecycle awareness
- Context-free dialogs support

---

MIT License © [zhengzaihong](https://github.com/zhengzaihong)

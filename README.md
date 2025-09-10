# 🚀 Router Pro · Routing & Lifecycle Awareness Tools

[![pub package](https://img.shields.io/pub/v/router_pro.svg)](https://pub.dev/packages/router_pro)
[![GitHub stars](https://img.shields.io/github/stars/zhengzaihong/router_lifecycle.svg?style=social)](https://github.com/zhengzaihong/router_lifecycle)
[![license](https://img.shields.io/github/license/zhengzaihong/router_lifecycle)](LICENSE)

Language: English | [简体中文](README-ZH.md)

---

## ✨ Why choose Router Pro?

In Flutter development, pages often need to have life cycle capabilities (`onResume`,`onPause`,`onDestroy`) like Android's **Activity/Fragment** for lazy loading or improved performance experience.  
However, Flutter's **StatelessWidget/StatefulWidget** does not natively support these features.

**Router Pro provides a solution：**

- 🔗 ** Routing agent **: easier page jumps and rollback
- ⏱ ** Life-cycle perception **: Stateless/StatefulWidget changes Activity/Fragment in seconds
- 🪶 ** Decoupled design **: Routing and life cycle are used independently
- 🌍 ** Cross-platform support **: App & Web

---

## 🌟 characteristics are as

- ✅ FLutter pages can also enjoy ** Native Life Cycle Awareness **
- ✅ Provide more elegant ** route jump/close API**
- ✅ ** Decoupled design **: Routing and lifecycle can be used separately
- ✅ Support ** Cross-platform (App & Web)**

## 📦 install

Add to `pubspec.yaml`：

```yaml
dependencies:
  router_pro: ^0.1.1 //Original flux_router_forzzh： 0.0.6 (the last version depends on the address, stop updating)
```

import：

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
  onResult: (value){ //optional
    setState((){
      title = "Taobao page$value";
    });
  });
router.pushNamed(
  name: '/TaoBaoPageDetail',
  onResult: (value){ //optional
    setState((){
      title = "Taobao page$value";
    });
  });
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



---

## 🛠 other explanatory

- `ExitWindowStyle`: Customizable prompt box to exit the program
- Web side: Support browser direct access, need to customize `RouteParser`



---

## 🎬 effect demonstration

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)


MIT License © [zhengzaihong](https://github.com/zhengzaihong)

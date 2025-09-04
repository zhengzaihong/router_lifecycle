# Routing tools and sensing Widget declaration cycles

Language: English | [简体中文](README-ZH.md)

### Preface:

In Flutter development, there are many cases where you want your page to
have lifecycle features like Android's Activity/Fragment, such as lazy
loading to improve performance and user experience. However, in Flutter,
StatelessWidget and StatefulWidget do not natively support detecting
whether a page is running in the foreground, background, or being
destroyed. Although StatefulWidget provides the dispose() callback when
destroyed, checking foreground/background status becomes difficult,
especially for pages built with StatelessWidget.

This utility library allows both StatelessWidget and StatefulWidget to
quickly gain lifecycle features similar to Android's Activity/Fragment:
onResume, onPause, onDestroy. The routing tool and lifecycle feature are
separated and decoupled, so you can use them independently.

# pubspec.yaml Dependency

    dependencies:
      router_plus: ^0.0.6 //Original flutter_router_forzzh: 0.0.6 (the last version depends on the address, stop updating)

#### Import package: import 'package:router_plus/router_lib.dart';

# Feature 1:

#### 1. Routing functionality for page navigation.

##### Define router globally for convenience:

      RouterProxy router = RouterProxy.getInstance(
          // routePathCallBack: (routeInformation) {
          //   print('routeInformation.location:${routeInformation.uri}');
          //   // Custom dynamic routing
          //   if (routeInformation.uri.toString() == 'TaoBaoPageDetail1') {
          //     return JdPageDetail();
          //   }
          // },
          // navigateToTargetCallBack: (context,page){
          //   router.currentTargetPage.value = page;
          // },
          pageMap: {'/': const Login()},
          exitWindowStyle:_confirmExit
      );
      
      Future<bool> _confirmExit(BuildContext context) async {
        final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Are you sure you want to exit the App?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  TextButton(
                    child: const Text('Confirm'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              );
            });
        return result ?? true;
      }

##### 2. Register RouterProxy in MaterialApp.router

    void main() {
      runApp(MyApp());
    }

    class MyApp extends StatelessWidget {
      MyApp({Key? key}) : super(key: key)
      @override
      Widget build(BuildContext context) {
        return MaterialApp.router(
          title: 'router_lifecycle',
          debugShowCheckedModeBanner: false,
          routerDelegate: router, // Bind routing tool
          routeInformationParser: router.defaultParser(), // Route parser, customizable
        );
      }
    }


    1. Use router.push(), router.pushNamed() etc. for page navigation.

    2. Use router.pop() to close a page.

# Feature 2:

#### 2. Add lifecycle listeners to pages where needed.

##### 2.1 StatefulWidget page:

##### 2.2 StatelessWidget page:

    class Login extends StatelessWidget {
    const Login({Key? key}) : super(key: key);
    @override
    Widget build(BuildContext context) {
      return LifeCycle(
        onCreate: (){
          print("--------Login onCreate");
        },
        onStart: (){
          print("--------Login onStart");
        },
        onResume: (){
          print("--------Login onResume");
        },
        onPause: (){
          print("--------Login onPause");
        },
        onDestroy: (){
          print("--------Login onDestroy");
        },
          child: Scaffold(
          body: Stack(
            children: [
              Container(
                constraints: const BoxConstraints.expand(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            side: const BorderSide(color: Colors.black),
                          ),
                          onPressed: () {
                            router.push(page: NavPage());
                          },
                          child: const Text('Login', style: TextStyle(color: Colors.black),),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
      ));
    }}

Other:

1.  exitWindowStyle: allows customizing the exit confirmation dialog.

2.  For web support, if you need browser direct navigation to a page,
    you need to customize routeInformationParser and extend the
    RouteParser class.

Effect:

![](https://github.com/zhengzaihong/router_lifecycle/blob/master/images/GIF.gif)

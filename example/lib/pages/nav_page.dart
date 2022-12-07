
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router_lib.dart';
import 'package:router_lifecycle_example/models/home_bottom_menu_bean.dart';
import 'package:router_lifecycle_example/pages/jd_page.dart';
import 'package:router_lifecycle_example/pages/taobao_page.dart';
import 'package:router_lifecycle_example/router_helper.dart';

class NavPage extends StatefulLifeCycle{

   NavPage({Key? key}) : super(key: key);

  State<StatefulWidget> getState(){
    return  _NavPageState();
  }

}

class _NavPageState extends State<NavPage> with TabPageObserve{

  final List<HomeBottomMenuBean> _bottomNavList = [
    HomeBottomMenuBean("淘宝","taobao_icon_1.png","taobao_icon_2.png",0),
    HomeBottomMenuBean("京东","jd_icon_1.png","jd_icon_2.png",1),
  ];




  int currentIndex = 0;
  final List<Widget> pageList = [
     TaoBaoPage(),
     JdPage(),
  ];



  @override
  TabPageInfo onCreateTabPage(){
    return TabPageInfo(
        uniqueId: pageList.hashCode,
        pages: pageList,
        checkPageIndex: 0);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(),
      body:IndexedStack(
        index: currentIndex,
        children: pageList,
      ),
      bottomNavigationBar:BottomNavigationBar(
        //配置选中的索引值
        currentIndex: currentIndex,
        onTap: (index) {
         setState(() {
           currentIndex = index;
           router.setTabChange(
               pageList[index],
               uniqueId:pageList.hashCode);
         });
        },
        selectedFontSize: 22,
        unselectedFontSize: 16,
        unselectedItemColor: Colors.grey,
        fixedColor: Colors.red,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        // BottomNavigationBarItem 包装的底部按钮
        items: [
          ..._buildBottomMenus()
        ],
      ) ,
    );
  }

  List<BottomNavigationBarItem> _buildBottomMenus(){
    List<BottomNavigationBarItem> list = [];
    for(int i =0 ;i<_bottomNavList.length;i++){
      BottomNavigationBarItem item = BottomNavigationBarItem(
          label: _bottomNavList[i].name,
          icon: currentIndex == i
              ? _bottomIcon(homeImage(_bottomNavList[i].checkedIcon))
              : _bottomIcon(homeImage(_bottomNavList[i].unCheckIcon)));

      list.add(item);
    }
    return list;
  }

  Widget _bottomIcon(path) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Image.asset(
          path,
          width: 26,
          height: 26,
          repeat: ImageRepeat.noRepeat,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ));
  }


}


String homeImage(String name) {
  return "assets/images/home/$name";
}
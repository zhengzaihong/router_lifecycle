
// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
///
/// create_user: zhengzaihong
/// Email:1096877329@qq.com
/// create_date: 2022-12-05
/// create_time: 12:07
/// describe 提供给 StatefulWidget的接口
///
abstract class StatefulLifeCycle<T extends State> extends StatefulWidget{

  final StatefulState statefulState = StatefulState();
  StatefulLifeCycle({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState(){
    if(statefulState.getState()==null){
      State<StatefulWidget> state = getState();
      statefulState.build(state);
      return state;
    }
    return statefulState.getState()!;
  }

  T getState();

}

class StatefulState{
  State<StatefulWidget>? _state;
  State<StatefulWidget>? getState(){
    return _state;
  }
  State<StatefulWidget> build(State<StatefulWidget> state){
    return _state = state;
  }
}
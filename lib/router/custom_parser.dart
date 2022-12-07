
import 'package:flutter/material.dart';
import 'package:flutter_router_forzzh/router/route_parser.dart';

///
/// create_user: zhengzaihong
/// email:1096877329@qq.com
/// create_date: 2022/12/7
/// create_time: 13:51
/// describe: 没做解析，外部需要自定义RouteParser
///
class CustomParser extends RouteParser {

  const CustomParser() : super();

  @override
  Future<List<RouteSettings>> parseRouteInformation(RouteInformation routeInformation) {
    return Future.value(List.empty());
  }

  @override
  RouteInformation restoreRouteInformation(List<RouteSettings> configuration) {
    final location = configuration.last.name;
    return RouteInformation(location: location);
  }
}

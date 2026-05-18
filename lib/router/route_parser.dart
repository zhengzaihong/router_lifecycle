import 'package:flutter/material.dart';

///
/// author:郑再红
/// email:1096877329@qq.com
/// date: 2022/12/7
/// time: 13:45
/// describe: 路由解析
/// Base parser type used by [RouterProxy] and custom route parsers.
///
abstract class RouteParser extends RouteInformationParser<RouteInformation> {
  const RouteParser() : super();
}

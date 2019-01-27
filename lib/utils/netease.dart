import 'dart:convert';

import 'package:dio/dio.dart';

import '../utils/crypto.dart';

final Dio dio = new Dio();
final host = 'https://music.163.com/';

class Netease {
  static get(uri, param) async {
    Map encrypted = Crypto.crypto(param);

    Response response = await dio.post(
        '${host}${uri}?params=${param['params']}&encSecKey=${param['encSecKey']}');
    return json.decode(response.data);
  }
}

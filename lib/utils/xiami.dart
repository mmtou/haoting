import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

final Dio dio = new Dio();

final host = "https://www.xiami.com";

class Xiami {
  static get(uri, param) async {
    Response<String> xmResponse = await dio.get(host);
    xmResponse.headers['set-cookie'];
    var cookies = dio.cookieJar.loadForRequest(Uri.parse(host));
    var cookieMap = {};
    cookies.forEach((item) {
      cookieMap[item.name] = item.value;
    });

    var _param = json.encode(param);

    var q = Uri.encodeQueryComponent(_param);
    var s = md5.convert(new Utf8Encoder().convert(
        '${cookieMap['xm_sg_tk'].split('_')[0]}_xmMain_${uri}_${_param}'));
    Response response = await dio.get("${host}${uri}?_q=${q}&_s=${s}",
        options: Options(headers: {
          'authority': 'www.xiami.com',
          'pragma': 'no-cache',
          'cache-control': 'no-cache',
          'upgrade-insecure-requests': '1',
          'user-agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36',
          'accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
          'accept-encoding': 'gzip, deflate, br',
          'accept-language': 'zh,en-US;q=0.9,en;q=0.8,zh-HK;q=0.7'
        }));
    return response.data;
//    if (data['url'] != null) {
//      // 滑块验证
//      var punishUrl = 'https:${data['url']}';
//      Response punishResponse = await dio.get(punishUrl);
//      var document = parse(punishResponse.data);
//      var inputs = document.getElementsByTagName('input');
//      // 分析
//      var analyzeUrl =
//          'https://cf.aliyun.com/nocaptcha/analyze.jsonp?a=X82Y&t=${inputs[1].attributes['value']}&n=115%23${md5.convert(new Utf8Encoder().convert(DateTime.now().toString()))}&p=%7B%22ncSessionID%22%3A%225e701ed8198d%22%7D&scene=register&asyn=0&lang=cn&v=948&callback=jsonp_04307619434900687';
////      Response analyzeResponse = await dio.get(analyzeUrl);
////      print(analyzeResponse.data);
//
////      var validateUrl = 'https://www.xiami.com/api/search/searchSongs/_____tmd_____/verify/?nc_token=${inputs[1].attributes['value']}&nc_session_id=${inputs[2].attributes['value']}&nc_sig=${inputs[3].attributes['value']}&x5secdata=${inputs[4].attributes['value']}&x5step=${inputs[5].attributes['value']}';
////      Response validateResponse = await dio.get(validateUrl);
////      print(validateResponse.data);
//      return;
//    }
  }
}

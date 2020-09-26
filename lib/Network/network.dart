import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/parsing.dart';

class NetWork {
  NetWork({this.retrieveAsDesktopPage = false, this.gbkDecoding = false, this.autoRedirect = true}) {
    dio = Dio();
  }

  Dio dio;
  bool retrieveAsDesktopPage;
  bool gbkDecoding;
  bool autoRedirect;
  Map<String, dynamic> queryHeaders = {
    "Host": "www.ditiezu.com",
    "Cache-Control": "max-age=0",
    "Origin": "http://www.ditiezu.com",
    "Upgrade-Insecure-Requests": "1",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
    "Referer": "http://www.ditiezu.com/member.php?mod=logging&action=login&mobile=yes",
    "Connection": "keep-alive"
  };

  // {"Referer": "http://www.ditiezu.com/", "Origin": "http://www.ditiezu.com/", "Host": "www.ditiezu.com", "DNT": "1", "Proxy-Connection": "keep-alive"};

  Future<Dio> openConn() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    var cookieJar = PersistCookieJar(dir: appDocPath + "/.cookies/");
    dio.interceptors.add(CookieManager(cookieJar));
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      if (retrieveAsDesktopPage)
        client.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537 (KHTML, like Gecko) Chrome/87 Safari/537";
      else
        client.userAgent = "Mozilla/5.0 (Linux; Android 6.0;) AppleWebKit/537 (KHTML, like Gecko) Chrome/87 Mobile Safari/537";
      client.findProxy = (uri) {
        // return "PROXY 127.0.0.1:8888";
        return "PROXY 192.168.50.201:8888";
      };
      // client.badCertificateCallback =
      //     (X509Certificate cert, String host, int port) => true;
    };
    return dio;
  }

  Future<String> get(String url) async {
    dio = await openConn();
    var result = await dio.get(url,
        options: Options(
            responseType: gbkDecoding ? ResponseType.bytes : ResponseType.plain,
            headers: queryHeaders,
            followRedirects: false,
            validateStatus: (code) {
              return true;
            }));
    if (result.statusCode >= 300 && result.statusCode <= 399) {
      if (autoRedirect) {
        result = await dio.get("http://www.ditiezu.com" + result.headers["location"][0]);
      } else
        return result.headers["location"][0];
    }
    return gbkDecoding ? gbk.decode(result.data) : result.data.toString();
  }

  Future<String> post(String url, String formData) async {
    dio = await openConn();
    dio.options.contentType = "application/x-www-form-urlencoded";
    var result = await dio.post(url,
        data: formData,
        options: Options(
            responseType: gbkDecoding ? ResponseType.bytes : ResponseType.plain,
            headers: queryHeaders,
            followRedirects: false,
            validateStatus: (code) {
              return true;
            }));
    if (result.statusCode >= 300 && result.statusCode <= 399) {
      if (autoRedirect) {
        result = await dio.get("http://www.ditiezu.com" + result.headers["location"][0]);
      } else
        return result.headers["location"][0];
    }
    return gbkDecoding ? gbk.decode(result.data) : result.data.toString();
  }

  Future<bool> checkLogin() async {
    return parseHtmlDocument(await get("http://www.ditiezu.com/forum.php?gid=149")).querySelector("#lsform") == null ? true : false;
  }
}

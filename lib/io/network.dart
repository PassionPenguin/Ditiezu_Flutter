import 'dart:developer';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/parsing.dart';

const String hostName = "www.ditiezu.com";
const String hostIP = "http://218.93.127.46/";
const String userAgent =
    "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/39 Mobile/15E148 Version/15.0";
Map<String, String> queryHeaders = {
  "Host": hostName,
  "Cache-Control": "max-age=0",
  "Origin": hostName,
  "Accept":
      "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
  "Referer":
      "http://www.ditiezu.com/member.php?mod=logging&action=login&mobile=yes",
  "Connection": "keep-alive"
};

class NetWork {
  NetWork({this.autoRedirect = true, this.gbkDecoding = true}) {
    retrieveAsDesktopPage = true;
    dio = Dio();
  }

  NetWork.mobile({this.autoRedirect = true, this.gbkDecoding = false}) {
    retrieveAsDesktopPage = false;
    dio = Dio();
  }

  late Dio dio;
  late bool retrieveAsDesktopPage;
  bool gbkDecoding;
  bool autoRedirect;

  Future<Dio> openConn() async {
    var path =
        join((await getApplicationDocumentsDirectory()).path, ".cookies");
    var cookieJar = PersistCookieJar(storage: FileStorage(path));
    dio.interceptors.add(CookieManager(cookieJar));
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      if (retrieveAsDesktopPage) {
        client.userAgent =
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537 (KHTML, like Gecko) Chrome/87 Safari/537";
      } else {
        client.userAgent =
            "Mozilla/5.0 (Linux; Android S/2;) AppleWebKit/537 (KHTML, like Gecko) Chrome/87 Mobile Safari/537";
      }
      // client.findProxy = (uri) {
      //   return "PROXY 192.168.50.201:8888";
      // };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };
    return dio;
  }

  Future<String> get(String url) async {
    log("GET $url");
    dio = await openConn();
    Response result;
    result = await dio.get(hostIP + url,
        options: Options(
            responseType: gbkDecoding ? ResponseType.bytes : ResponseType.plain,
            headers: queryHeaders,
            followRedirects: false,
            validateStatus: (code) {
              return true;
            }));
    if (result.statusCode! >= 300 && result.statusCode! <= 399) {
      if (autoRedirect) {
        result = await dio.get(hostIP + result.headers["location"]![0]);
      } else {
        return result.headers["location"]![0];
      }
    }
    return gbkDecoding ? gbk.decode(result.data) : result.data.toString();
  }

  Future<String> post(String url, String formData) async {
    log("POST $url");
    dio = await openConn();
    dio.options.contentType = "application/x-www-form-urlencoded";

    var result;
    try {
      result = await dio.post(hostIP + url,
          data: formData,
          options: Options(
              responseType:
                  gbkDecoding ? ResponseType.bytes : ResponseType.plain,
              headers: queryHeaders,
              followRedirects: false,
              validateStatus: (code) {
                return true;
              }));
    } catch (e) {}
    if (result.statusCode >= 300 && result.statusCode <= 399) {
      if (autoRedirect) {
        result = await dio.get(hostIP + result.headers["location"][0]);
      } else {
        return result.headers["location"][0];
      }
    }
    return gbkDecoding ? gbk.decode(result.data) : result.data.toString();
  }

  Future<String> postMultipart(String url, FormData formData) async {
    log("POST $url");
    dio = await openConn();

    var result;
    try {
      result = await dio.post(hostIP + url,
          data: formData,
          options: Options(
              responseType:
                  gbkDecoding ? ResponseType.bytes : ResponseType.plain,
              headers: queryHeaders,
              followRedirects: false,
              validateStatus: (code) {
                return true;
              }));
    } catch (e) {}
    if (result.statusCode >= 300 && result.statusCode <= 399) {
      if (autoRedirect) {
        result = await dio.get(hostIP + result.headers["location"][0]);
      } else {
        return result.headers["location"][0];
      }
    }
    return gbkDecoding ? gbk.decode(result.data) : result.data.toString();
  }

  Future<List<String>> retrieveRedirect(String url) async {
    log("GET $url");
    dio = await openConn();

    var result;
    try {
      result = await dio.get(hostIP + url,
          options: Options(
              responseType:
                  gbkDecoding ? ResponseType.bytes : ResponseType.plain,
              headers: queryHeaders,
              followRedirects: false,
              validateStatus: (code) {
                return true;
              }));
    } catch (e) {}
    if (result.statusCode >= 300 && result.statusCode <= 399) {
      var href = result.headers["location"][0];
      var tid = href.substring(href.indexOf("tid=") + 4,
          href.indexOf("&", href.indexOf("tid=") + 4));
      var page = href.substring(href.indexOf("page=") + 5,
          href.indexOf("#", href.indexOf("page=") + 5));
      return [tid, page];
    }
    return ["-1", "1"];
  }

  Future<bool> checkLogin() async {
    return parseHtmlDocument(
                    await get("http://www.ditiezu.com/forum.php?gid=149"))
                .querySelector("#lsform") ==
            null
        ? true
        : false;
  }
}

import 'dart:developer';

import 'package:ditiezu/models/thread_item.dart';
import 'package:ditiezu/models/topic_item.dart';
import 'package:ditiezu/models/user.dart';

class ExtractLink {
  Topic extractForumInformation(String url) {
    var uri = Uri.tryParse(url), defaultTopic = Topic(-1, -1);
    if (uri == null) return defaultTopic;
    if (uri.path.startsWith("/forum.php")) {
      int id = int.tryParse((uri.queryParameters['fid']).toString()) ?? -1;
      int page = int.tryParse((uri.queryParameters['page']).toString()) ?? 1;
      return Topic(id, page);
    } else {
      var match = RegExp(r"forum-(\d+?)-(\d+?).html").firstMatch(url);
      if (match == null) return defaultTopic;
      try {
        return Topic(int.parse(match.group(1).toString()),
            int.parse(match.group(2).toString()));
      } catch (e) {
        log(e.toString());
        return defaultTopic;
      }
    }
  }

  Thread extractThreadInformation(String url) {
    var uri = Uri.tryParse(url), defaultThread = Thread(-1, -1);
    if (uri == null) return defaultThread;
    if (uri.path.startsWith("/forum.php")) {
      int id = int.tryParse((uri.queryParameters['tid']).toString()) ?? -1;
      int page = int.tryParse((uri.queryParameters['page']).toString()) ?? 1;
      return Thread(id, page);
    } else {
      var match = RegExp(r"thread-(\d+?)-(\d+?)-1.html").firstMatch(url);
      if (match == null) return Thread(-1, -1);
      try {
        return Thread(int.parse(match.group(1).toString()),
            int.parse(match.group(2).toString()));
      } catch (e) {
        log(e.toString());
        return defaultThread;
      }
    }
  }

  User extractUserInformation(String url, String username) {
    var match = RegExp(r"space-uid-(\d+?).html").firstMatch(url);
    if (match == null) return User();
    try {
      return User.init(name: username, id: int.tryParse(match.group(1)!)!);
    } catch (e) {
      log(e.toString());
      return User();
    }
  }
}

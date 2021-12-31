import 'dart:convert';

import 'package:ditiezu/models/user.dart';

class ThreadItem {
  String threadTitle;
  User author;
  String pubDate;
  String badge;
  Thread thread;
  String enclosureUrl = "";
  int views = 0;
  int replies = 0;

  bool isHot = false;
  bool isNew = false;
  bool withImage = false;
  bool withAttachment = false;
  bool timeIsToday = false;
  ThreadItem({
    required this.threadTitle,
    required this.author,
    required this.badge,
    required this.thread,
    this.pubDate = "",
    this.enclosureUrl = "",
    this.views = 0,
    this.replies = 0,
    this.isHot = false,
    this.isNew = false,
    this.withImage = false,
    this.withAttachment = false,
    this.timeIsToday = false,
  });

  ThreadItem copyWith({
    String? threadTitle,
    User? author,
    String? pubDate,
    String? badge,
    Thread? thread,
    String? enclosureUrl,
    int? views,
    int? replies,
    bool? isHot,
    bool? isNew,
    bool? withImage,
    bool? withAttachment,
    bool? timeIsToday,
  }) {
    return ThreadItem(
      threadTitle: threadTitle ?? this.threadTitle,
      author: author ?? this.author,
      pubDate: pubDate ?? this.pubDate,
      badge: badge ?? this.badge,
      thread: thread ?? this.thread,
      enclosureUrl: enclosureUrl ?? this.enclosureUrl,
      views: views ?? this.views,
      replies: replies ?? this.replies,
      isHot: isHot ?? this.isHot,
      isNew: isNew ?? this.isNew,
      withImage: withImage ?? this.withImage,
      withAttachment: withAttachment ?? this.withAttachment,
      timeIsToday: timeIsToday ?? this.timeIsToday,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'threadTitle': threadTitle,
      'author': author.toMap(),
      'pubDate': pubDate,
      'badge': badge,
      'thread': thread.toMap(),
      'enclosureUrl': enclosureUrl,
      'views': views,
      'replies': replies,
      'isHot': isHot,
      'isNew': isNew,
      'withImage': withImage,
      'withAttachment': withAttachment,
      'timeIsToday': timeIsToday,
    };
  }

  factory ThreadItem.fromMap(Map<String, dynamic> map) {
    return ThreadItem(
      threadTitle: map['threadTitle'],
      author: User.fromMap(map['author']),
      pubDate: map['pubDate'],
      badge: map['badge'],
      thread: Thread.fromMap(map['thread']),
      enclosureUrl: map['enclosureUrl'],
      views: map['views'],
      replies: map['replies'],
      isHot: map['isHot'],
      isNew: map['isNew'],
      withImage: map['withImage'],
      withAttachment: map['withAttachment'],
      timeIsToday: map['timeIsToday'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ThreadItem.fromJson(String source) =>
      ThreadItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ThreadItem(threadTitle: $threadTitle, author: $author, pubDate: $pubDate, badge: $badge, thread: $thread, enclosureUrl: $enclosureUrl, views: $views, replies: $replies, isHot: $isHot, isNew: $isNew, withImage: $withImage, withAttachment: $withAttachment, timeIsToday: $timeIsToday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ThreadItem &&
        other.threadTitle == threadTitle &&
        other.author == author &&
        other.pubDate == pubDate &&
        other.badge == badge &&
        other.thread == thread &&
        other.enclosureUrl == enclosureUrl &&
        other.views == views &&
        other.replies == replies &&
        other.isHot == isHot &&
        other.isNew == isNew &&
        other.withImage == withImage &&
        other.withAttachment == withAttachment &&
        other.timeIsToday == timeIsToday;
  }

  @override
  int get hashCode {
    return threadTitle.hashCode ^
        author.hashCode ^
        pubDate.hashCode ^
        badge.hashCode ^
        thread.hashCode ^
        enclosureUrl.hashCode ^
        views.hashCode ^
        replies.hashCode ^
        isHot.hashCode ^
        isNew.hashCode ^
        withImage.hashCode ^
        withAttachment.hashCode ^
        timeIsToday.hashCode;
  }
}

class Thread {
  Thread(
    this.id,
    this.page,
  );

  final int id;
  final int page;

  Thread copyWith({
    int? id,
    int? page,
  }) {
    return Thread(
      id ?? this.id,
      page ?? this.page,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'page': page,
    };
  }

  factory Thread.fromMap(Map<String, dynamic> map) {
    return Thread(
      map['id'],
      map['page'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Thread.fromJson(String source) => Thread.fromMap(json.decode(source));

  @override
  String toString() => 'Thread(id: $id, page: $page)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Thread && other.id == id && other.page == page;
  }

  @override
  int get hashCode => id.hashCode ^ page.hashCode;
}

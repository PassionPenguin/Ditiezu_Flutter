class ThreadItem {
  ThreadItem(this.threadTitle, this.threadContent, this.authorName, this.pubDate, this.badge, this.threadID, this.threadPage, this.authorUID, this.views, this.replies, this.isHot, this.isNew, this.withImage, this.withAttachment, this.timeIsToday);

  ThreadItem.rss(this.threadTitle, this.threadContent, this.authorName, this.pubDate, this.badge, this.threadID, this.threadPage, this.enclosureUrl, this.authorUID, this.views, this.replies);

  String threadTitle;
  String threadContent;
  String authorName;
  String pubDate;
  String badge;
  int threadID;
  int threadPage;
  String enclosureUrl;
  int authorUID = 0;
  int views = 0;
  int replies = 0;

  bool isHot;
  bool isNew;
  bool withImage;
  bool withAttachment;
  bool timeIsToday;
}

class NotificationItem {
  final String imageUrl;
  final String value;
  final String description;
  final String time;
  final String tid;
  final String page;

  NotificationItem({this.imageUrl, this.value, this.description, this.time, this.tid = "-1", this.page = "1"});
}

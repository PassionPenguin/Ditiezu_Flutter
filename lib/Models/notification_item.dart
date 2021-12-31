class NotificationItem {
  final String imageUrl;
  final String value;
  final String description;
  final String time;
  final String tid;
  final String page;

  NotificationItem({required this.imageUrl, required this.value, required this.description, required this.time, this.tid = "-1", this.page = "1"});
}

class TopicItem {
  TopicItem(this.topicName, this.topicDescription, this.topicIcon, this.topicID, this.backgroundName);

  String topicName;
  String topicDescription;
  String topicIcon;
  int topicID;
  String backgroundName;
}

class Topic {
  final int id;
  final int page;

  Topic(this.id, this.page);
}
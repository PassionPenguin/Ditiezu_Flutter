class PostItem<T> {
  PostItem(this.content, this.authorName, this.authorUID, this.postTime, this.pid, this.editable);

  final String content;
  final String authorName;
  final int authorUID;
  final String postTime;
  final int pid;
  final bool editable;
}

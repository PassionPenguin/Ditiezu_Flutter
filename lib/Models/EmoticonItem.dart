class EmoticonItem {
  EmoticonItem(this.insert, this.src);

  String insert;
  String src;
}

class EmoticonsItem{
  EmoticonsItem(this.src, this.list, this.name);

  String src;
  List<EmoticonItem> list;
  String name;
}
class SelectItem {
  String name;
  bool isSelected = false;
  int id = -1;

  SelectItem(this.name);

  SelectItem.full({this.name, this.isSelected, this.id});
}

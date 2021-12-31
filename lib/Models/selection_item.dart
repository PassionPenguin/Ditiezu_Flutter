class SelectItem {
  String name;
  bool isSelected = false;
  int id = -1;

  SelectItem(this.name);

  SelectItem.full({required this.name, required this.isSelected, required this.id});
}

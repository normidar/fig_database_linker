part of fig_database_linker;

///浮点数型,在sqlite上是32位
class FieldFloat extends AbsNumField {
  FieldFloat(
      {this.description,
      this.signed = true,
      this.nullAllow = true,
      this.unique = false,
      this.defaultValue});
  String typeStr = 'float';
  int length;
  String description;
  bool signed; //true为有符号
  bool nullAllow;
  bool unique;
  dynamic defaultValue;

  @override
  Map<String, dynamic> toData() {
    var rt = super.toData();
    rt['signed'] = signed;
    return rt;
  }
}

part of fig_database_linker;

///字符串型
///
class FieldStr extends FieldAbs {
  FieldStr(
      {this.length = 16,
      this.description,
      this.nullAllow = true,
      this.unique = false,
      this.defaultValue});
  String typeStr = 'str';
  int length;
  String description;
  bool nullAllow;
  bool unique;
  dynamic defaultValue;
}

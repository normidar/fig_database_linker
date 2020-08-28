part of fig_database_linker;

///字符串型
class FieldDate extends FieldAbs {
  FieldDate(
      {this.description,
      this.nullAllow = true,
      this.unique = false,
      this.defaultValue});
  String typeStr = 'date';
  String description;
  bool nullAllow;
  bool unique;
  dynamic defaultValue;
}

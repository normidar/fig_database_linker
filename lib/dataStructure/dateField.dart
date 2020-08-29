part of fig_database_linker;

///日期型,TEXT: "YYYY-MM-DD HH:MM:SS.SSS"
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
  bool isDefaultValueWithNow = false;
  dynamic defaultValue;
}

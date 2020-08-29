part of fig_database_linker;

///货币数数型,自定义小数点前后,在sqlite上自适应
class FieldDecimal extends AbsNumField {
  FieldDecimal(this.font, this.end,
      {this.description,
      this.signed = true,
      this.nullAllow = true,
      this.unique = false,
      this.defaultValue});
  String typeStr = 'decimal';
  int font;
  int end;
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

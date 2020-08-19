part of fig_database_linker;
///整数型
///
class FieldInt extends FieldAbs{
  FieldInt({
    this.length=16,
    this.description,
    this.signed=true,
    this.nullAllow=true,
    this.unique=false,
    this.defaultValue
  });
  String typeStr = 'int';
  int length ;
  String description;
  bool signed;//true为有符号
  bool nullAllow;
  bool unique;
  dynamic defaultValue;

  @override
  Map<String,dynamic> toData() {
    var rt = super.toData();
    rt['signed'] = signed;
    return rt;
  }
  @override
  Map<String,dynamic> toWidgets() {
    Map<String,dynamic> rt = {};
    rt['name'] = 'name';
    rt['length'] = 16;
    rt['nullAllow'] = true;
    rt['unique'] = false;
    rt['signed'] = true;
    rt['defaultValue'] = '';
    rt['description'] = '';
    return rt;
  }
}


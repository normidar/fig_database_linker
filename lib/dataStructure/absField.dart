part of fig_database_linker;

///用于表示
abstract class FieldAbs {
  String typeStr;
  String description;
  int length;
  bool nullAllow = true;
  bool unique = false;
  Map<String, dynamic> toData() {
    var rt = {};
    rt['name'] = typeStr;
    rt['description'] = description;
    rt['length'] = length;
    rt['nullAllow'] = nullAllow;
    rt['unique'] = unique;
    rt['defaultValue'] = defaultValue;
    return rt;
  }

  Map<String, dynamic> toWidgets() {
    Map<String, dynamic> rt = {};
    rt['name'] = 'name';
    rt['length'] = 16;
    rt['nullAllow'] = true;
    rt['unique'] = false;
    rt['defaultValue'] = '';
    rt['description'] = '';
    return rt;
  }

  dynamic defaultValue;
}

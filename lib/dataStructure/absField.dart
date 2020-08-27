part of fig_database_linker;

///用于表示创建数据库时的数据类型
abstract class FieldAbs {
  ///返回一个此类型的表示字符串
  String typeStr;

  ///注释,但并未应用
  String description;

  ///长度,但在某些数据库中会忽视长度
  int length;

  ///是否允许空
  bool nullAllow = true;

  ///默认类型,未完整
  dynamic defaultValue;

  ///是否唯一
  bool unique = false;

  ///返回一个map以表示此类型的数据
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
}

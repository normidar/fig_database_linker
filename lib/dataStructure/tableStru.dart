part of fig_database_linker;
///此类是保存一个表的数据类型
class TableStru{
  TableStru(this.tableName,{this.primaryKey = 'id'});
  String tableName;
  String primaryKey;
  Map<String,FieldAbs> types={};
  Map<String,dynamic> toData(){
    Map<String,dynamic> rt = {};
    rt['tableName'] = tableName;
    rt['primaryKey'] = primaryKey;
    Map<String,dynamic> fields = {};
    for(var i in types.keys){
      fields[i] = types[i].toData();
    }
    rt['fields'] = fields;
    return rt;
  }
  void addType(String fieldName,FieldAbs field){
    types[fieldName] = field;
  }
}

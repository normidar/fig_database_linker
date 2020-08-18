
part of fig_database_linker;


class DataLinkerSqlite extends DataLinkerAbs {
  DataLinkerSqlite(this.card) : super(card);
  LinkSets card;
  Database _conn;
  Map<String,String> _idFieldName = {};
  List<String> fields =[];
  Future getConn() async {
    var path = join(await getDatabasesPath(),card.host + '.db');
    _conn =await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
        );
      },
       version: 1
    );
  }

  //获取数据库
  Future<List<String>> getTables() async {
    _conn.insert('dogs', 
          {
            'name': 'name',
            'age': '7',
          }
        );
    List<Map<String, dynamic>> result = await _conn.query(
      "sqlite_master",
      // where: 'type = ?',
      // whereArgs: ['table']
    );
    List<String> rt = result.map((v) {
      return v['name'].toString();
    }).toList();
    //删除一个系统创建的表
    rt.removeWhere((value) => value == 'android_metadata');
    return rt;
  }

  //运行sql并返回处理工具
  Future<List<Map<String, dynamic>>> _getRows(String sql) async {
    var results = await _conn.rawQuery(sql);
    return results;
  }
  //运行sql返回一张表
  Future<List<List<String>>> getRows(String sql) async {
    var results = await _getRows(sql);
    var rt = results.map((v) {
      var rt = v.values.map((v) {
        return v.toString();
      }).toList();
      return rt;
    }).toList();
    fields =results.first.keys.toList();
    rt.insert(0,fields );
    return rt;
  }
  @override
  Future<List<String>> getFields({String sql='',String table = ''})async{
    if(fields.isNotEmpty){
      return fields;
    }else{
      if(sql.isNotEmpty){
        var results = await _getRows(sql);
        fields = results.first.keys.toList();
        return fields;
      }
      return fields;
    }
  }
  //进行预览表的搜索
  Future<List<List<String>>> getTableView(String table) async {
    return await getRows("SELECT * FROM $table order by 1 desc LIMIT 20");
  }
  Future<int> _addData(String table,Map data)async{
    try{
      var rt = await _conn.insert(table, data);
      return rt;
    }catch(e){
      throw e;
    }
  }
  //增
  @override
  Future<int> addDataToTable(String table,List dddata,{Function(bool) inputF,Function(int,int) overInput}) async{
    List<Map<String,dynamic>> data = dddata;
    int ts = 0;
    int fs = 0;
    for(var m in data){
      var line = await _addData(table, m);
      if(line > 0){
        ts++;
        if(inputF != null){
          inputF(true);
        }
      }else{
        fs++;
        if(inputF != null){
          inputF(false);
        }
      }
    }
    if(overInput != null){
      overInput(ts,fs);
    }
    return ts;
  }
  @override
  Future closeDatabase() {
    return _conn.close();
  }

  @override
  Future deleteData(String table,String id)async {
    var s = await _conn.delete(table,where : await getKey(table) + " = ?",whereArgs: [id]);
    return s;
  }
  
  @override
  Future<String> getKey(String table)async{
    //没有就去搜索
    if(_idFieldName[table] == null){
      try{
        var tableData = await _getRows("pragma table_info ('$table')");
        for(var i in tableData){
          if(i['pk'] == 1){
            _idFieldName[table] =i['name'];
            return _idFieldName[table];
          }
        }
      }catch(e){
        
      }
    }
    return 'id';
  }
  @override
  Future<int> updataData(String table, Map<String,dynamic> data)async {
    var idName = await getKey(table);
    return _conn.update(table, data,where: idName + '= ?',whereArgs: [data[idName]]);
  }
}

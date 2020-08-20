part of fig_database_linker;



class DataLinkerPostgres extends DataLinkerAbs{
  LinkSets card;
  DataLinkerPostgres(this.card):super(card);
  PostgreSQLConnection _conn;
  List<String> fields =[];
  Map<String,String> typeStrs = {
    'int':'INT',
    'str':'VARCHAR',
  };
  Future<String> createTable(TableStru tableStru,{bool ifNotExistsCreatMode = true})async{
    var ifNotExistsStr = ifNotExistsCreatMode ? 'IF NOT EXISTS ' : '';
    //postgres不支持无符号,但提供了实现
    String start = 'CREATE TABLE '+ ifNotExistsStr +tableStru.tableName+' (';
    String body ='\n  ' + tableStru.primaryKey + ' serial PRIMARY KEY,' ;

    var types = tableStru.types;
    for(var i in types.keys){
      var value =types[i];
      String line = '\n  ' + i + ' ';
      line += typeStrs[types[i].typeStr];
      //int 后不用加长度
      if(!(types[i] is FieldInt))line += '(' + value.length.toString() +') ';
      //当数字类型且无符号时加上无符号
      if(value is FieldInt && !value.signed)line += ' CHECK(' +i+ '>=0)';
      //唯一
      if(value.unique)line += ' UNIQUE';
      //非空
      if(!types[i].nullAllow)line += ' NOT NULL';
      //默认
      if(types[i].defaultValue != null)line += ' DEFAULT \''+types[i].defaultValue + '\'' ;
      //加末尾逗号
      line += ',';
      body += line;
    }
    //减去末尾逗号
    body = body.substring(0,body.length-1);
    String end = '\n);';
    //生成用于创建数据表的sql
    var sql = start + body + end;
    await _getRows(
      sql
    );
    return sql;
  }
  Future<String> getConn() async{
    _conn = PostgreSQLConnection(
      card.host,
      int.parse(card.port ?? 5432),
      card.db,
      username: card.user,
      password: card.psw,
    );
    await _conn.open();
    return _conn.isClosed.toString();
  }
  //获取数据库
  Future<List<String>> getTables()async{
    List<List<dynamic>> results = await _conn?.query(
      'select tablename from pg_tables'
    );
    List<String> rt = [];
    for(var i in results ?? [[]]){
      rt.add(i[0].toString());
    }
    return rt;
  }
  //运行sql并返回处理工具
  Future<List<List<dynamic>>> _getRows(String sql)async{
    List<List<dynamic>> results = await _conn.query(sql);
    return results;
  }
  //运行sql返回一张表
  Future<List<List<String>>> getRows(String sql)async{
    var results =await _getRows(sql);
    var rt = results.map((v)=>v.map((d)=>d.toString()).toList()).toList();
    return rt;
  }
  @override
  Future<List<String>> getFields({String sql='',String table = ''})async{
    
  }
  //进行预览表的搜索
  Future<List<List<String>>> getTableView(String table)async{
    var results = await _conn.query("SHOW KEYS FROM $table WHERE Key_name = 'PRIMARY'");
    try{
      var primaryKey =results.first[4];//断点查看后发现在4,或许其它数据库会变
      return await getRows("SELECT * FROM $table ORDER BY $primaryKey DESC LIMIT 20");
    }catch(e){
      return await getRows("SELECT * FROM $table order by 1 desc LIMIT 20");
    }
  }
  //一个辅助函数
  Future<int> _addData(String table,Map data)async{
    // try{
    //   var fields = data.keys.join(',');
    //   //在每个子值中加入引号
    //   var valueList = data.values.map((e) => "'"+e+"'");
    //   var values = valueList.join(',');
    //   //组合SQL并运行
    //   var sql = "INSERT INTO " + table + ' ('+fields+') VALUES (' + values+')';
    //   var results = await _getRows(sql);
    //   var rt = results.length;
    //   return rt;
    // }catch(e){
    //   throw e;
    // }
  }
  @override
  Future<int> addDataToTable(String table,List dddata,{Function(bool) inputF,Function(int,int) overInput})async{
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
  Future deleteData(String table,String id) async{
      // await this._conn.query("delete from $table where "+await getKey(table)+'=?',[id]);
  }

  @override
  Future<String> getKey(String table)async {
    var results = await _conn.query("SHOW KEYS FROM $table WHERE Key_name = 'PRIMARY'");
    try{
      var primaryKey =results.first[4];//断点查看后发现在4,或许其它数据库会变
      return primaryKey;
    }catch(e){
      return 'id';
    }
  }
  @override
  Future<int> updataData(String table, Map<String,dynamic> data)async {
    // var idName = await getKey(table);
    // var setString = '';
    // //循环合成SET的成员
    // for(var k in data.keys){
    //   if(k != idName){
    //     setString += k+"='"+data[k]+"',";
    //   }
    // }
    // //保证有数据被更新
    // if(setString == ''){
    //   return 0;
    // }else{
    //   //去除最后一个逗号
    //   setString = setString.substring(0,setString.length -1);
    // }
    // //保证data中有ID键
    // if(data.containsKey(idName)){
    //   var sql = 'update ' +table+' SET ' + setString+' where ' + idName + '=' + data[idName];    
    //   var results = await _getRows(sql);
    //   return results.length;
    // }else{
    //   return 0;
    // }
  }
}

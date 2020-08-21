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
    List<List<dynamic>> results = await _getRealRows(sql);
    return results;
  }
  Future<PostgreSQLResult> _getRealRows(String sql){
    return _conn.query(sql);
  }
  //运行sql返回一张表
  Future<List<List<String>>> getRows(String sql)async{
    var results =await _getRows(sql);
    var rt = results.map((v)=>v.map((d)=>d.toString()).toList()).toList();
    return rt;
  }
  ///完成
  @override
  Future<List<String>> getFields({String sql='',String table = ''})async{
    var sqlSets =
    '''
    SELECT a.attname AS field
    FROM pg_class c, pg_attribute a
        LEFT JOIN pg_description b
        ON a.attrelid = b.objoid
            AND a.attnum = b.objsubid, pg_type t
    WHERE c.relname = '$table'
        AND a.attnum > 0
        AND a.attrelid = c.oid
        AND a.atttypid = t.oid
    ORDER BY a.attnum;
    ''';
    //首先检测table项,如果没有再检测sql项
    if(table.isNotEmpty){
      var result = await getRows(sqlSets);
      var rt =<String>[];
      for(var i in result)rt.add(i[0]);
      return rt;
    }else if(sql.isNotEmpty){
      var results = await _getRealRows(sql);
      return results.first.toColumnMap().keys.toList();
    }
    return null;
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
  String _getAddDataSql(String table,Map data){
    var fields = data.keys.join(',');
    //在每个子值中加入引号
    var valueList = data.values.map((e) => "'"+e+"'");
    var values = valueList.join(',');
    //组合SQL并运行
    var sql = "INSERT INTO " + table + ' ('+fields+') VALUES (' + values+')';
    return sql;
  }
  @override
  Future<String> addDataToTable(String table,List<Map<String,dynamic>> data)async{
    var ts = '';
    for(var m in data){
      var sql = _getAddDataSql(table, m);
      await _getRows(sql);
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
  Future<String> getIdName(String table)async {
    var sqlSets =
    '''
    SELECT
        pg_attribute.attname AS colname
    FROM
        pg_constraint
    INNER JOIN pg_class ON pg_constraint.conrelid = pg_class.oid
    INNER JOIN pg_attribute ON pg_attribute.attrelid = pg_class.oid
    AND pg_attribute.attnum = pg_constraint.conkey [ 1 ]
    WHERE
        pg_class.relname = '$table'
    AND pg_constraint.contype = 'p';
    ''';
    var result = await getRows(sqlSets);
    return result[0][0];
  }
  ///you can let id in data and set idName with prm.when you no set idName we will findit in table.
  @override
  Future<String> updataDataById(String table, Map<String,dynamic> data,{String idName = ''})async {
    if(idName.isEmpty)idName = await getIdName(table);
    var setString = '';
    //循环合成SET的成员
    for(var k in data.keys){
      if(k != idName){
        setString += k+"='"+data[k]+"',";
      }
    }
    //保证有数据被更新并去除最后逗号,否则返回
    if(setString == '')return '0 have not data';else
      setString = setString.substring(0,setString.length -1);
    
    //保证data中有ID键,否则返回
    if(data.containsKey(idName)){
      var sql = 'UPDATE ' +table+' \nSET ' + setString+' \nWHERE ' + idName + '=' + data[idName];    
      var results = await _getRows(sql);
      return results.toString();
    }else{
      return '0 id miss';
    }
  }
}

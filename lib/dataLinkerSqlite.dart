part of fig_database_linker;

class DataLinkerSqlite extends DataLinkerAbs {
  DataLinkerSqlite(this.card, {this.testMode = false}) : super(card);
  bool testMode;
  LinkSets card;
  Database _conn;
  Map<String, String> typeStrs = {
    'int': 'INTEGER',
    'str': 'TEXT',
    'float': 'REAL',
    'date': 'TEXT',
  };

  ///host,
  Future getConn() async {
    var path = join(await getDatabasesPath(), card.host + '.db');
    _conn = await openDatabase(path, version: 1);
  }

  //创建数据表
  Future<String> createTable(TableStru tableStru) async {
    String start = 'CREATE TABLE ' + tableStru.tableName + '(\n';
    String body =
        tableStru.primaryKey + ' INTEGER PRIMARY KEY AUTOINCREMENT,\n';
    var types = tableStru.types;
    for (var i in types.keys) {
      var value = types[i];
      //类型名
      String line = i + ' ' + typeStrs[value.typeStr];
      //
      if (value is AbsNumField && !value.signed) line += ' CHECK($i >= 0)';
      if (!value.nullAllow) line += ' NOT NULL';
      if (value.defaultValue != null)
        line += ' DEFAULT \'' + value.defaultValue + '\'';
      if (value.unique) line += ' UNIQUE';
      //注释
      line +=
          ',' + (value.description==null ? value.description : '') + '\n';
      //添加到主体
      body += line;
    }
    //减去末尾逗号
    body = body.substring(0, body.length - 2);
    String end = '\n);';
    var sql = start + body + end;
    //测试模式
    if (testMode == false) await _getRows(sql);
    return sql;
  }

  //获取数据库
  Future<List<String>> getTables() async {
    _conn.insert('dogs', {
      'name': 'name',
      'age': '7',
    });
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
    var rt =
        results.map((v) => v.values.map((v) => v.toString()).toList()).toList();
    return rt;
  }

  @override
  Future<List<String>> getFields({String sql = '', String table = ''}) async {
    if (table.isNotEmpty) {
      sql = 'PRAGMA  table_info($table)';
      var results = await _getRows(sql);
      var rt = results.map((row) => row['name'].toString()).toList();
      return rt;
    } else if (sql.isNotEmpty) {
      var results = await _getRows(sql);
      if (results.length > 0) {
        return results.first.keys.toList();
      }
    }
    return null;
  }

  //进行预览表的搜索
  Future<List<List<String>>> getTableView(String table,
      {int count = 20, bool desc = true}) async {
    return await getRows("SELECT * FROM $table order by 1" +
        (desc ? ' DESC' : '') +
        " LIMIT " +
        count.toString());
  }

  Future<int> _addData(String table, Map data) async {
    var rt = await _conn.insert(table, data);
    return rt;
  }

  //增
  @override
  Future<String> addDataToTable(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    for (var m in data) {
      await _addData(table, m);
    }
    return 'ts';
  }

  @override
  Future closeDatabase() {
    return _conn.close();
  }

  @override
  Future deleteDataById(String table, String id) async {
    var s = await _conn
        .delete(table, where: await getIdName(table) + " = ?", whereArgs: [id]);
    return s;
  }

  @override
  Future<String> getIdName(String table) async {
    var tableData = await _getRows("pragma table_info ('$table')");
    for (var i in tableData) {
      if (i['pk'] == 1) {
        return i['name'];
      }
    }
    return null;
  }

  @override
  Future<int> updataDataById(String table, Map<String, dynamic> data) async {
    var idName = await getIdName(table);
    return _conn
        .update(table, data, where: idName + '= ?', whereArgs: [data[idName]]);
  }

  Future deleteTable(String table) async {
    _getRows('DROP TABLE ' + table + ';');
  }
}

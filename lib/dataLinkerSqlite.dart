part of fig_database_linker;

class DataLinkerSqlite extends DataLinkerAbs {
  /// card just only need host as path to link sqlite.
  DataLinkerSqlite(this.card, {this.testMode = false}) : super(card);
  bool testMode;
  LinkSets card;
  Database _conn;

  ///主要用的是key来进行
  Map<String, bool> allTables;
  Map<String, String> typeStrs = {
    'int': 'INTEGER',
    'str': 'TEXT',
    'float': 'REAL',
    'date': 'TEXT',
    'decimal': 'NUMERIC',
  };

  ///host,
  Future getConn({bool setTableList = true}) async {
    var path = join(await getDatabasesPath(), card.host + '.db');
    _conn = await openDatabase(path, version: 1);
    //设置一个所有表的列表
    if (setTableList) {
      allTables = {};
      var results = await _getRows('select name fromsqlite_master;');
      for (var i in results) {
        allTables[i['name']] = true;
      }
    }
  }

  //创建数据表
  Future<String> createTable(TableStru tableStru,
      {bool ifNotExistsCreatMode = true}) async {
    //是否选择表安全创建
    var ifNotExistsStr = ifNotExistsCreatMode ? 'IF NOT EXISTS ' : '';
    String start =
        'CREATE TABLE ' + ifNotExistsStr + tableStru.tableName + '(\n';
    String body =
        tableStru.primaryKey + ' INTEGER PRIMARY KEY AUTOINCREMENT,\n';
    var types = tableStru.types;
    //一个计数器,目的为让最后的行不加逗号
    var index = 0;
    var count = types.length;
    for (var i in types.keys) {
      index++;
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
      if (index != count) line += ',';
      if (value.description != null) line += ' -- ' + value.description;
      line += '\n';
      //添加到主体
      body += line;
    }
    String end = ');';
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

  ///会查找并返回,
  ///当输入updateData的时候会对查找结果进行更新,
  ///更新时,返回情况依数据库而异请不要依赖.
  ///如果设置两个add的话将会执行增加的操作,此也不返回.
  Future<List<List<String>>> where(String table, String field, String value,
      {Map<String, dynamic> updateData,
      String addField,
      double addValue}) async {
    //当更新数据为空,则仅仅查找
    if (updateData != null) {
      await _conn
          .update(table, updateData, where: field + ' = ?', whereArgs: [value]);
      return null;
    } else if (addField != null && addValue != null) {
      var sql = "UPDATE " +
          table +
          " SET " +
          addField +
          '=' +
          addField +
          '+' +
          addValue.toString() +
          ' WHERE ' +
          field +
          " = '" +
          value +
          "'";
      return await getRows(sql);
    } else {
      return await getRows(
          "SELECT * FROM " + table + " WHERE " + field + " = '" + value + "'");
    }
  }

  @override
  Future<int> updataDataById(String table, Map<String, dynamic> data) async {
    var idName = await getIdName(table);
    return await _conn
        .update(table, data, where: idName + '= ?', whereArgs: [data[idName]]);
  }

  Future deleteTable(String table) async {
    _getRows('DROP TABLE ' + table + ';');
  }
}

part of fig_database_linker;

class DataLinkerMysql extends DataLinkerAbs {
  LinkSets card;
  DataLinkerMysql(this.card) : super(card);
  MySqlConnection _conn;
  List<String> fields = [];
  Map<String, String> typeStrs = {
    'int': 'INT',
    'str': 'VARCHAR',
  };
  //初始化
  Future getConn() async {
    var settings = ConnectionSettings(
        host: card.host,
        port: int.parse(card.port ?? 3306),
        user: card.user,
        password: card.psw,
        db: card.db);
    this._conn = await MySqlConnection.connect(settings);
  }

  //创建数据表
  Future createTable(TableStru tableStru) async {
    //未实现无符号
    String start = 'CREATE TABLE IF NOT EXISTS `' + tableStru.tableName + '`(';
    String body = tableStru.primaryKey + ' INT(11) UNSIGNED AUTO_INCREMENT,';
    String uniques = '';

    var types = tableStru.types;
    for (var i in types.keys) {
      var value = types[i];
      String line = ' `' + i + '` ';
      line += typeStrs[types[i].typeStr];
      line += '(' + value.length.toString() + ')';
      //当数字类型且无符号时加上无符号

      if (value is FieldInt && !value.signed) line += ' UNSIGNED';
      if (!types[i].nullAllow) line += ' NOT NULL';
      if (types[i].defaultValue != null)
        line += ' DEFAULT \'' + types[i].defaultValue + '\'';
      if (types[i].unique) uniques += '`' + i + '`,';

      //此句最后
      line += ',';
      body += line;
    }
    //删掉尾部逗号
    if (uniques != '') uniques = uniques.substring(0, uniques.length - 1);
    //主键
    body += 'PRIMARY KEY (`' + tableStru.primaryKey + '`)';
    //唯一
    if (uniques != '') body += ',UNIQUE KEY `uid` (' + uniques + ')';
    String end = ')ENGINE=InnoDB DEFAULT CHARSET=utf8;';
    //生成用于创建数据表的sql
    var sql = start + body + end;
    await _getRows(sql);
  }

  //获取数据表数据
  Future<List<String>> getTables() async {
    if (_conn != null && card.db != null) {
      Results results = await _conn.query('SHOW TABLES');
      List<String> rt = [];
      for (var row in results) {
        rt.add(row[0]);
      }
      return rt;
    } else {
      return [];
    }
  }

  //运行sql并返回处理工具
  Future<Results> _getRows(String sql) async {
    if (_conn != null && card.db != null) {
      Results results;
      results = await _conn.query(sql);
      return results;
    } else {
      return null;
    }
  }

  //运行sql返回一张表
  Future<List<List<String>>> getRows(String sql) async {
    var results = await _getRows(sql);
    List<List<String>> rt = [];
    if (results.isNotEmpty) {
      for (var row in results) {
        rt.add(row.values.toList().map((d) => d.toString()).toList()); //注意类型
      }
    }
    return rt;
  }

  @override
  Future<List<String>> getFields({String sql = '', String table = ''}) async {
    if (table.isNotEmpty) {
      sql = "SHOW COLUMNS FROM $table ";
      var results = await _getRows(sql);
      fields = results.map((v) => v.fields['Field'].toString()).toList();
      return fields;
    } else if (sql.isNotEmpty) {
      var results = await _getRows(sql);
      fields = results.fields.map((v) => v.name).toList();
      return fields;
    }
    return null;
  }

  //进行预览表的搜索
  Future<List<List<String>>> getTableView(String table,
      {int count = 20, bool desc = true}) async {
    return await getRows("SELECT * FROM $table ORDER BY " +
        await getIdName(table) +
        (desc ? ' DESC' : '') +
        " LIMIT " +
        count.toString());
  }

  //一个辅助函数
  Future<String> _getAddDataSql(String table, Map data) async {
    var fields = data.keys.join(',');
    //在每个子值中加入引号
    var valueList = data.values.map((e) => "'" + e + "'");
    var values = valueList.join(',');
    //组合SQL并运行
    var sql =
        "INSERT INTO " + table + ' (' + fields + ') VALUES (' + values + ')';
    return sql;
  }

  @override
  Future<String> addDataToTable(String table, List data) async {
    var sql = '';
    for (var m in data) {
      sql = await _getAddDataSql(table, m);
    }
    _getRows(sql);
    return sql;
  }

  @override
  Future closeDatabase() {
    return _conn.close();
  }

  @override
  Future deleteDataById(String table, String id) async {
    await this._conn.query(
        "delete from $table where " + await getIdName(table) + '=?', [id]);
  }

  @override
  Future<String> getIdName(String table) async {
    var results =
        await _conn.query("SHOW KEYS FROM $table WHERE Key_name = 'PRIMARY'");
    var primaryKey = results.first.fields['Column_name']; //断点查看后发现在4,或许其它数据库会变
    return primaryKey;
  }

  @override
  Future<int> updataDataById(String table, Map<String, dynamic> data) async {
    var idName = await getIdName(table);
    var setString = '';
    //循环合成SET的成员
    for (var k in data.keys) {
      if (k != idName) {
        setString += k + "='" + data[k] + "',";
      }
    }
    //保证有数据被更新
    if (setString == '') {
      return 0;
    } else {
      //去除最后一个逗号
      setString = setString.substring(0, setString.length - 1);
    }
    //保证data中有ID键
    if (data.containsKey(idName)) {
      var sql = 'update ' +
          table +
          ' SET ' +
          setString +
          ' where ' +
          idName +
          '=' +
          data[idName];
      var results = await _getRows(sql);
      return results.length;
    } else {
      return 0;
    }
  }

  Future deleteTable(String table) async {
    _getRows('DROP TABLE ' + table + ';');
  }
}

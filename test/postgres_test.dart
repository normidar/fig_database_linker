import 'package:flutter_test/flutter_test.dart';

import 'package:fig_database_linker/fig_database_linker.dart';

void main() {
  LinkSets sets = LinkSets(
    'raja.db.elephantsql.com',
    '5432',
    'wabjtpfp',
    'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
    'wabjtpfp',
  );
  test('测试postgres的数据库连接',()async{
    var link = DataLinkerPostgres(sets);
    var g =await link.getConn();
    await link.closeDatabase();
  });
  test('创建表,测试postgres数据库的功能', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    TableStru tableStru =TableStru('ccc');
    tableStru.primaryKey = 'id';
    tableStru.addType('dogs', FieldInt(signed:false));
    tableStru.addType('nam', FieldStr(defaultValue: 'test',nullAllow: false,description: 'abcccc'));
    print(await link.createTable(tableStru));
    await link.closeDatabase();
  });
  test('插入数据,测试postgres数据库', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.addDataToTable('ccc', [{'dogs':'123','nam':'123'}]));
    await link.closeDatabase();
  });
  test('更新数据,测试postgres数据库', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.updataDataById('ccc', {'id':'1','dogs':'12','nam':'1234'}));
    await link.closeDatabase();
  });
  test('测试postgres数据库的查询字段名功能', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.getFields(table: 'ccc'));
    await link.closeDatabase();
  });
  test('测试postgres数据库的sql查询字段名功能', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.getFields(sql:'SELECT * FROM "public"."ccc"'));
    await link.closeDatabase();
  });
  test('获取主键名,测试postgres数据库', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.getIdName('ccc'));
    await link.closeDatabase();
  });
  test('表预览,测试postgres数据库', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    var str = (await link.getTableView('ccc')).toString();
    print(str);
    await link.closeDatabase();
  });
  test('用id删除数据,测试postgres数据库', ()async{
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.deleteDataById('ccc', '2'));
    await link.closeDatabase();
  });
  test('删除表,测试postgres数据库', ()async{
    // var link = DataLinkerPostgres(sets);
    // await link.getConn();
    // await link.deleteTable('ccc');
    // await link.closeDatabase();
  });
}

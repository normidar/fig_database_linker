import 'package:flutter_test/flutter_test.dart';

import 'package:fig_database_linker/fig_database_linker.dart';

void main() async{
  LinkSets sets = LinkSets(
    host:'raja.db.elephantsql.com',
    port:'5432',
    user:'wabjtpfp',
    psw:'nQBIM1-c9WS-_Nh78l-nytTnyn_QIFZ7',
    db:'wabjtpfp',
  );
  var link = DataLinkerPostgres(sets)..getConn();
  
  test('测试postgres的数据库连接',()async{
    await link.getConn();
  });
  test('创建表,测试postgres数据库的功能', ()async{
    TableStru tableStru =TableStru('ccc');
    tableStru.primaryKey = 'id';
    tableStru.addType('dogs', FieldInt(signed:false));
    tableStru.addType('nam', FieldStr(defaultValue: 'test',nullAllow: false,description: 'abcccc'));
    print(await link.createTable(tableStru));
  });
  test('插入数据,测试postgres数据库', ()async{
    print(await link.addDataToTable('ccc', [{'dogs':'123','nam':'123'}]));
  });
  test('更新数据,测试postgres数据库', ()async{
    print(await link.updataDataById('ccc', {'id':'1','dogs':'12','nam':'1234'}));
  });
  test('测试postgres数据库的查询字段名功能', ()async{
    print(await link.getFields(table: 'ccc'));
  });
  test('测试postgres数据库的sql查询字段名功能', ()async{
    print(await link.getFields(sql:'SELECT * FROM "public"."ccc"'));
  });
  test('获取主键名,测试postgres数据库', ()async{
    print(await link.getIdName('ccc'));
  });
  test('表预览', ()async{
    var str = (await link.getTableView('ccc')).toString();
    print(str);
  });
  test('用id删除数据,测试postgres数据库', ()async{
    print(await link.deleteDataById('ccc', '1'));
  });
  test('删除表,测试postgres数据库', ()async{
    await link.getConn();
    await link.deleteTable('ccc');
  });
  test('关闭,测试postgres数据库', ()async{
    // await link.closeDatabase();
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:fig_database_linker/fig_database_linker.dart';

void main() async{
  LinkSets sets = LinkSets(
    host:'ccc',
  );
  var link = DataLinkerSqlite(sets,testMode: true);
  
  test('创建表', ()async{
    TableStru tableStru =TableStru('ccc');
    tableStru.addType('dogs', FieldInt(signed:false));
    tableStru.addType('nam', FieldStr(defaultValue: 'test',nullAllow: false,description: 'abcccc'));
    print(await link.createTable(tableStru));
  });
  test('插入数据', ()async{
    await link.getConn();
    print(await link.addDataToTable('ccc', [{'dogs':'123','nam':'123'}]));
    print(await link.addDataToTable('ccc', [{'dogs':'1234','nam':'1234'}]));
  });
  test('更新数据', ()async{
    await link.getConn();
    print(await link.updataDataById('ccc', {'id':'1','dogs':'12','nam':'1234'}));
  });
  test('查询字段名', ()async{
    await link.getConn();
    print(await link.getFields(table: 'ccc'));
  });
  test('用sql查字段名', ()async{
    print(await link.getFields(sql:'SELECT * FROM ccc'));
  });
  test('获取主键名', ()async{
    print(await link.getIdName('ccc'));
  });
  test('表预览', ()async{
    // var str = (await link.getTableView('ccc',desc: true)).toString();
    // print(str);
  });
  test('用id删除数据', ()async{
    print(await link.deleteDataById('ccc', '1'));
  });
  test('删除表', ()async{
    // await link.deleteTable('ccc');
  });
  test('关闭连接', ()async{
    await link.closeDatabase();
  });
}

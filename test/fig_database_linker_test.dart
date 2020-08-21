import 'package:flutter_test/flutter_test.dart';

import 'package:fig_database_linker/fig_database_linker.dart';

void main() {
  test('adds one to input values', () {
    
    // final calculator = Calculator();
    // expect(calculator.addOne(2), 3);
    // expect(calculator.addOne(-7), -6);
    // expect(calculator.addOne(0), 1);
    // expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });
  test('测试postgres的数据库连接',()async{
    LinkSets sets = LinkSets(
      'raja.db.elephantsql.com',
      '5432',
      'wabjtpfp',
      'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
      'wabjtpfp',
    );
    var link = DataLinkerPostgres(sets);
    var g =await link.getConn();
    print(g);
  });
  test('创建表,测试postgres数据库的功能', ()async{
    LinkSets sets = LinkSets(
      'raja.db.elephantsql.com',
      '5432',
      'wabjtpfp',
      'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
      'wabjtpfp',
    );
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    TableStru tableStru =TableStru('cba');
    tableStru.primaryKey = 'di';
    tableStru.addType('dogs', FieldInt(unique: true,signed:false));
    tableStru.addType('nam', FieldStr(defaultValue: 'test',nullAllow: false,description: 'abcccc'));
    print(await link.createTable(tableStru));

  });
    test('测试postgres数据库的查询字段名功能', ()async{
    LinkSets sets = LinkSets(
      'raja.db.elephantsql.com',
      '5432',
      'wabjtpfp',
      'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
      'wabjtpfp',
    );
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.getFields(table: 'abc'));
    link.closeDatabase();
  });
  test('测试postgres数据库的sql查询字段名功能', ()async{
    LinkSets sets = LinkSets(
      'raja.db.elephantsql.com',
      '5432',
      'wabjtpfp',
      'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
      'wabjtpfp',
    );
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.getFields(sql:'SELECT * FROM "public"."abc" LIMIT 100'));
    link.closeDatabase();
  });
  test('插入数据,测试postgres数据库', ()async{
    LinkSets sets = LinkSets(
      'raja.db.elephantsql.com',
      '5432',
      'wabjtpfp',
      'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
      'wabjtpfp',
    );
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.addDataToTable('cba', [{'dogs':'123','nam':'123'}]));
    link.closeDatabase();
  });
  test('更新数据,测试postgres数据库', ()async{
    LinkSets sets = LinkSets(
      'raja.db.elephantsql.com',
      '5432',
      'wabjtpfp',
      'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
      'wabjtpfp',
    );
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.updataDataById('cba', {'di':'1','dogs':'12','nam':'1234'}));
    link.closeDatabase();
  });
  test('获取id,测试postgres数据库', ()async{
    LinkSets sets = LinkSets(
      'raja.db.elephantsql.com',
      '5432',
      'wabjtpfp',
      'Q5q05nP9mcDUY9V3bWidtwegWxU9IO_J',
      'wabjtpfp',
    );
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    print(await link.getIdName('cba'));
    link.closeDatabase();
  });
}

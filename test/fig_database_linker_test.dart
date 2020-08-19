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
}

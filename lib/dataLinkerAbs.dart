

import 'dataLinkItem.dart';

abstract class DataLinkerAbs {
  final LinkSets card;
  DataLinkerAbs(this.card);

  Future getConn();
  //获取数据库
  Future<List<String>> getTables();
  //运行sql返回一张表
  Future<List<List<String>>> getRows(String sql);
  //获取所有的字段
  Future<List<String>> getFields({String sql='',String table = ''});
  //进行预览表的搜索
  Future<List<List<String>>> getTableView(String table);
  //通过SQL截取表名
  String getTableName(String sql){
    var lowerWrite = sql.toLowerCase();
    var index = lowerWrite.indexOf(' from ');
    if(index == -1){
      return null;
    }else{
      //切割,去除空格,再切割
      var cut = sql.substring(index + 5);
      cut = cut.trimLeft();
      //获2号空格位置
      var spaceIndex = cut.indexOf(' ');
      if(spaceIndex == -1) return cut;
      cut = cut.substring(0,spaceIndex);
      return cut;
    }
  }
  //获取键
  Future<String> getKey(String table);
  //关闭数据库
  Future closeDatabase();
  //增
  Future<int> addDataToTable(String table,List dddata,{Function(bool) inputF,Function(int,int) overInput});
  //删
  Future deleteData(String table,String id);
  //改ata
  Future<int> updataData(String table,Map<String,dynamic> data);
}

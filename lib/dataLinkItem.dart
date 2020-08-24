part of fig_database_linker;


class LinkSets{
  String host,port,user,psw,db;
  //注意:第一个必须是title
  LinkSets({this.host,this.port,this.user,this.psw,this.db});
  LinkSets.m(Map<String,dynamic> map){
    this.map = map;
  }
  set map(Map<String,dynamic> m){
    host = m['host'];
    port = m['port'];
    user = m['user'];
    psw = m['psw'];
    db = m['db'];
  }
}

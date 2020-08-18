part of fig_database_linker;


class LinkSets{
  int id;
  String title,type,host,port,user,psw,db;
  //注意:第一个必须是title
  LinkSets(this.title,this.type,this.host,this.port,this.user,this.psw,this.db,{this.id,});
  LinkSets.m(Map<String,dynamic> map){
    this.map = map;
  }
  set map(Map<String,dynamic> m){
    title = m['title'];
    type = m['type'];
    host = m['host'];
    port = m['port'];
    user = m['user'];
    psw = m['psw'];
    db = m['db'];
  }
}

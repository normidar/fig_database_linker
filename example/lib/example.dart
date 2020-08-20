import 'package:fig_database_linker/fig_database_linker.dart';

main()async{
    LinkSets sets = LinkSets(
      'host',
      '5432(port)',
      'username',
      'password',
      'database name',
    );
    var link = DataLinkerPostgres(sets);
    await link.getConn();
    TableStru tableStru =TableStru('abh');
    tableStru.addType('dogs', FieldInt(unique: true,signed:false));
    tableStru.addType('nam', FieldStr(defaultValue: 'test',nullAllow: false,description: 'abcccc'));
    print(await link.createTable(tableStru));

}

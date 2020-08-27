library fig_database_linker;

import 'package:mysql1/mysql1.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:postgres/postgres.dart';

part 'dataLinkerAbs.dart';
part 'dataLinkerMysql.dart';
part 'dataLinkerPostgres.dart';
part 'dataLinkerSqlite.dart';
part 'dataLinkItem.dart';

part 'dataStructure/absField.dart';
part 'dataStructure/absNumField.dart';
part 'dataStructure/intField.dart';
part 'dataStructure/floatField.dart';
part 'dataStructure/strField.dart';
part 'dataStructure/tableStru.dart';

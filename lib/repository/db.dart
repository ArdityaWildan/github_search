import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  Future<Database> getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'main.db'),
      onCreate: (db, version) {
        db.execute(
          """CREATE TABLE fetch_cache(
          search_query TEXT,
          search_type TEXT, 
          page INTEGER,
          valid_until TEXT, 
          data TEXT)""",
        );
      },
      version: 1,
    );
  }
}

import 'dart:convert';

import 'package:github_search/bloc/mode/mode_state.dart';
import 'package:github_search/model/issue.dart';
import 'package:github_search/model/repository.dart';
import 'package:github_search/model/searchable.dart';
import 'package:github_search/model/user.dart';

import 'db.dart';

class GithubCacheRepository {
  final db = Db();

  Future<void> add({
    required SearchType searchType,
    required String query,
    required int page,
    required List<Searchable> data,
  }) async {
    final database = await db.getDatabase();
    await database.insert(
      'fetch_cache',
      {
        'search_query': query,
        'search_type': searchType.toString(),
        'page': page,
        'valid_until':
            DateTime.now().add(const Duration(minutes: 10)).toString(),
        'data': data.toString(),
      },
    );
  }

  Future<List<Searchable>?> fetch({
    required SearchType searchType,
    required String query,
    required int page,
  }) async {
    await clean();
    final now = DateTime.now();
    final database = await db.getDatabase();
    final data = await database.query(
      'fetch_cache',
      where:
          'valid_until >= \'$now\' AND search_type=\'$searchType\' AND search_query=\'$query\' AND page=$page',
      limit: 1,
    );
    if (data.isEmpty) return null;
    final selected = data.first;
    String searchableListString = selected['data'].toString();
    final mapped =
        json.decode(searchableListString).cast<Map<String, dynamic>>();
    List<Searchable> results = [];
    switch (searchType) {
      case SearchType.user:
        results = mapped
            .map<User>(
              (json) => User.fromLocalJson(json),
            )
            .toList();
        break;
      case SearchType.repository:
        results = mapped
            .map<Repository>(
              (json) => Repository.fromLocalJson(json),
            )
            .toList();
        break;
      case SearchType.issue:
        results = mapped
            .map<Issue>(
              (json) => Issue.fromLocalJson(json),
            )
            .toList();
        break;
    }
    return results;
  }

  Future<void> clean() async {
    final now = DateTime.now();
    final database = await db.getDatabase();
    await database.delete(
      'fetch_cache',
      where: 'valid_until < \'$now\'',
    );
  }
}

import 'dart:convert';

import 'package:github_search/model/searchable.dart';
import 'package:intl/intl.dart';

class Repository extends Searchable {
  final String name;
  final String owner;
  final String url;
  final String createdAt;
  final int totalWatchers;
  final int totalStars;
  final int totalForks;

  Repository({
    required this.name,
    required this.owner,
    required this.url,
    required this.createdAt,
    required this.totalWatchers,
    required this.totalStars,
    required this.totalForks,
  });

  factory Repository.fromRemoteJson(
      Map<String, dynamic> data, DateFormat dateFormat) {
    return Repository(
      name: data['name'],
      owner: data['owner']['login'],
      url: data['html_url'],
      createdAt: dateFormat.format(DateTime.parse(data['created_at'])),
      totalWatchers: data['watchers_count'],
      totalStars: data['stargazers_count'],
      totalForks: data['forks_count'],
    );
  }

  factory Repository.fromLocalJson(Map<String, dynamic> data) {
    return Repository(
      name: data['name'],
      owner: data['owner'],
      url: data['url'],
      createdAt: data['createdAt'],
      totalWatchers: data['totalWatchers'],
      totalStars: data['totalStars'],
      totalForks: data['totalForks'],
    );
  }

  @override
  String toString() {
    final asJson = {
      'name': name,
      'owner': owner,
      'url': url,
      'createdAt': createdAt,
      'totalWatchers': totalWatchers,
      'totalStars': totalStars,
      'totalForks': totalForks,
    };
    return json.encode(asJson);
  }
}

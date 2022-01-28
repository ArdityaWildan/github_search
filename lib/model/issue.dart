import 'dart:convert';

import 'package:github_search/model/searchable.dart';
import 'package:intl/intl.dart';

class Issue extends Searchable {
  final String title;
  final String url;
  final String state;
  final String updatedAt;

  Issue({
    required this.title,
    required this.url,
    required this.state,
    required this.updatedAt,
  });

  factory Issue.fromRemoteJson(
      Map<String, dynamic> data, DateFormat dateFormat) {
    return Issue(
      title: data['title'],
      url: data['html_url'],
      state: data['state'],
      updatedAt: dateFormat.format(DateTime.parse(data['updated_at'])),
    );
  }

  factory Issue.fromLocalJson(Map<String, dynamic> data) {
    return Issue(
      title: data['title'],
      url: data['url'],
      state: data['state'],
      updatedAt: data['updatedAt'],
    );
  }

  @override
  String toString() {
    final asJson = {
      'title': title,
      'url': url,
      'state': state,
      'updatedAt': updatedAt,
    };
    return json.encode(asJson);
  }
}

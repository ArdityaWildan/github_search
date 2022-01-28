import 'dart:convert';

import 'package:github_search/model/searchable.dart';

class User extends Searchable {
  final String name;
  final String url;
  final String avatarUrl;

  User({
    required this.name,
    required this.url,
    required this.avatarUrl,
  });

  factory User.fromRemoteJson(Map<String, dynamic> data) {
    return User(
      name: data['login'],
      url: data['html_url'],
      avatarUrl: data['avatar_url'],
    );
  }

  factory User.fromLocalJson(Map<String, dynamic> data) {
    return User(
      name: data['name'],
      url: data['url'],
      avatarUrl: data['avatarUrl'],
    );
  }

  @override
  String toString() {
    final asJson = {
      'name': name,
      'url': url,
      'avatarUrl': avatarUrl,
    };
    return json.encode(asJson);
  }
}

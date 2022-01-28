import 'dart:async';

import 'package:github_search/repository/common_response.dart';
import 'package:github_search/repository/remote_defaults.dart';
import 'package:http/http.dart' as http;

import '../logger.dart';

class GithubRemoteRepository {
  final RemoteDefaults remoteDefaults = RemoteDefaults();

  Future<CommonResponse> fetchRepository(int page, String query) {
    final request = http.get(
      Uri.parse(
          'https://api.github.com/search/repositories?q=$query&page=$page&per_page=20'),
    );
    dlog('repository remote fetch : $page');
    return remoteDefaults.defaultRequest(request);
  }

  Future<CommonResponse> fetchIssue(int page, String query) {
    final request = http.get(
      Uri.parse(
          'https://api.github.com/search/issues?q=$query&page=$page&per_page=20'),
    );
    dlog('issue remote fetch : $page');
    return remoteDefaults.defaultRequest(request);
  }

  Future<CommonResponse> fetchUser(int page, String query) {
    final request = http.get(
      Uri.parse(
          'https://api.github.com/search/users?q=$query&page=$page&per_page=20'),
    );
    dlog('user remote fetch : $page');
    return remoteDefaults.defaultRequest(request);
  }
}

import 'package:github_search/bloc/mode/mode_state.dart';
import 'package:github_search/model/searchable.dart';

class FetchCache {
  final SearchType searchType;
  final String query;
  final int page;
  final DateTime validUntil;
  final List<Searchable> data;

  FetchCache({
    required this.searchType,
    required this.query,
    required this.page,
    required this.validUntil,
    required this.data,
  });
}

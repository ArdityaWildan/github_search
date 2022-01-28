import 'package:equatable/equatable.dart';
import 'package:github_search/bloc/mode/mode_state.dart';
import 'package:github_search/model/searchable.dart';
import 'package:github_search/repository/common_response.dart';

enum SearchStatus { searching, success, failed }

class SearchState extends Equatable {
  final SearchType searchType;
  final SearchStatus searchStatus;
  final ResponseErrorType? errorType;
  final List<Searchable> data;
  final bool isReachedMax;
  final int page;
  final int lastPage;
  final String query;

  const SearchState({
    this.searchType = SearchType.user,
    this.searchStatus = SearchStatus.success,
    this.data = const <Searchable>[],
    this.isReachedMax = false,
    this.page = 1,
    this.lastPage = 50,
    this.errorType,
    this.query = '',
  });

  SearchState copy({
    SearchType? searchType,
    SearchStatus? searchStatus,
    List<Searchable>? data,
    bool? isReachedMax,
    int? page,
    int? lastPage,
    ResponseErrorType? errorType,
    String? query,
  }) {
    return SearchState(
      searchType: searchType ?? this.searchType,
      searchStatus: searchStatus ?? this.searchStatus,
      data: data ?? this.data,
      isReachedMax: isReachedMax ?? this.isReachedMax,
      page: page ?? this.page,
      lastPage: lastPage ?? this.lastPage,
      errorType: errorType,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [
        searchType,
        searchStatus,
        data,
        isReachedMax,
        page,
        errorType,
        query,
      ];
}

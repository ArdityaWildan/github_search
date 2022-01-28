import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_search/bloc/mode/mode_state.dart';
import 'package:github_search/model/issue.dart';
import 'package:github_search/model/repository.dart';
import 'package:github_search/model/searchable.dart';
import 'package:github_search/model/user.dart';
import 'package:github_search/repository/common_response.dart';
import 'package:github_search/repository/github_cache_repository.dart';
import 'package:github_search/repository/github_remote_repository.dart';
import 'package:intl/intl.dart';

import '../../logger.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GithubRemoteRepository githubRemoteRepository;
  final GithubCacheRepository githubCacheRepository;
  final dateFormat = DateFormat('dd MMMM yyyy HH:mm:ss');

  SearchBloc({
    required this.githubRemoteRepository,
    required this.githubCacheRepository,
  }) : super(const SearchState()) {
    on<SearchFetch>(searchFetch);
  }

  void searchFetch(SearchFetch event, Emitter<SearchState> emit) async {
    final modeState = event.modeState;
    final displayType = modeState.displayType;
    final searchType = modeState.searchType;

    if (event.query.isEmpty) {
      emit(
        SearchState(
          searchType: searchType,
          data: const <Searchable>[],
          isReachedMax: false,
          page: 1,
          searchStatus: SearchStatus.success,
        ),
      );
      return;
    }
    final pageToLoad =
        event.query != state.query || searchType != state.searchType
            ? 1
            : event.page ??
                (event.fetchType == null
                    ? state.page
                    : (event.fetchType == FetchType.prev
                        ? state.page - 1
                        : state.page + 1));

    final needReset = state.data.isEmpty ||
        event.query != state.query ||
        !(searchType == SearchType.user
            ? state.data.last is User
            : searchType == SearchType.repository
                ? state.data.last is Repository
                : state.data.last is Issue);
    emit(
      state.copy(
        searchType: searchType,
        searchStatus: SearchStatus.searching,
        page: pageToLoad,
        query: event.query,
        data: displayType == DisplayType.paged || needReset
            ? <Searchable>[]
            : null,
      ),
    );

    // search in cache
    final cached = await githubCacheRepository.fetch(
      searchType: searchType,
      query: event.query,
      page: pageToLoad,
    );

    if (cached == null) {
      // send request

      CommonResponse response;
      switch (searchType) {
        case SearchType.user:
          response =
              await githubRemoteRepository.fetchUser(pageToLoad, event.query);
          break;
        case SearchType.repository:
          response = await githubRemoteRepository.fetchRepository(
              pageToLoad, event.query);
          break;
        case SearchType.issue:
          response =
              await githubRemoteRepository.fetchIssue(pageToLoad, event.query);
          break;
      }
      if (response.errorType == null) {
        final decodedResponse = json.decode(response.data);
        int possiblePages =
            ((decodedResponse['total_count'] / 20) as double).ceil();
        bool isReachedMax = pageToLoad >= 50 || possiblePages <= pageToLoad;

        List<Searchable> results = [];
        final mappedResult =
            decodedResponse['items'].cast<Map<String, dynamic>>();
        switch (searchType) {
          case SearchType.user:
            results = mappedResult
                .map<User>(
                  (json) => User.fromRemoteJson(json),
                )
                .toList();
            break;
          case SearchType.repository:
            results = mappedResult
                .map<Repository>(
                  (json) => Repository.fromRemoteJson(json, dateFormat),
                )
                .toList();
            break;
          case SearchType.issue:
            results = mappedResult
                .map<Issue>(
                  (json) => Issue.fromRemoteJson(json, dateFormat),
                )
                .toList();
            break;
        }

        // save to cache
        await githubCacheRepository.add(
          searchType: searchType,
          query: event.query,
          page: pageToLoad,
          data: results,
        );

        emit(
          state.copy(
            searchStatus: SearchStatus.success,
            data: displayType == DisplayType.infinite
                ? (List.of(state.data)..addAll(results))
                : results,
            isReachedMax: isReachedMax,
            lastPage: possiblePages < 1
                ? 1
                : possiblePages < 50
                    ? possiblePages
                    : 50,
          ),
        );
      } else {
        emit(
          state.copy(
            searchStatus: SearchStatus.failed,
            errorType: response.errorType,
          ),
        );
      }
    } else {
      // return from cache
      dlog('cache fetch');
      emit(
        state.copy(
          searchType: searchType,
          searchStatus: SearchStatus.success,
          data: displayType == DisplayType.infinite
              ? (List.of(state.data)..addAll(cached))
              : cached,
          isReachedMax: pageToLoad >= 50,
        ),
      );
    }
  }
}

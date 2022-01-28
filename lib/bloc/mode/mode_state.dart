import 'package:equatable/equatable.dart';

enum SearchType { user, repository, issue }
enum DisplayType { infinite, paged }

class ModeState extends Equatable {
  final SearchType searchType;
  final DisplayType displayType;

  const ModeState({
    this.searchType = SearchType.user,
    this.displayType = DisplayType.infinite,
  });

  ModeState copy({
    DisplayType? displayType,
    SearchType? searchType,
  }) {
    return ModeState(
      displayType: displayType ?? this.displayType,
      searchType: searchType ?? this.searchType,
    );
  }

  @override
  List<Object> get props => [searchType, displayType];
}

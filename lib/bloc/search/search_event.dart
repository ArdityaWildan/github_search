import 'package:equatable/equatable.dart';
import 'package:github_search/bloc/mode/mode_state.dart';

enum FetchType { next, prev }

abstract class SearchEvent extends Equatable {}

class SearchFetch extends SearchEvent {
  final FetchType? fetchType;
  final int? page;
  final String query;
  final ModeState modeState;

  SearchFetch({
    this.fetchType,
    this.page,
    required this.query,
    required this.modeState,
  });

  @override
  List<Object?> get props => [
        fetchType,
        page,
        query,
        modeState,
      ];
}

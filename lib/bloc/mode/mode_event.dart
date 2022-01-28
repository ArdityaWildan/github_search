import 'package:equatable/equatable.dart';
import 'package:github_search/bloc/mode/mode_state.dart';

abstract class ModeEvent extends Equatable {}

class TypeChange extends ModeEvent {
  final SearchType searchType;

  TypeChange(this.searchType);

  @override
  List<Object> get props => [searchType];
}

class DisplayChange extends ModeEvent {
  final DisplayType displayType;

  DisplayChange(this.displayType);

  @override
  List<Object> get props => [displayType];
}

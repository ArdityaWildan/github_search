import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_search/bloc/mode/mode_event.dart';
import 'package:github_search/bloc/mode/mode_state.dart';

class ModeBloc extends Bloc<ModeEvent, ModeState> {
  ModeBloc() : super(const ModeState()) {
    on<TypeChange>(typeChange);
    on<DisplayChange>(displayChange);
  }

  void typeChange(TypeChange event, Emitter<ModeState> emit) {
    if (state.searchType == event.searchType) return;
    emit(state.copy(searchType: event.searchType));
  }

  void displayChange(DisplayChange event, Emitter<ModeState> emit) {
    if (state.displayType == event.displayType) return;
    emit(state.copy(displayType: event.displayType));
  }
}

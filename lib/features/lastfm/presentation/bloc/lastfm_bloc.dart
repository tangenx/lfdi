import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'lastfm_event.dart';
part 'lastfm_state.dart';

class LastfmBloc extends Bloc<LastfmEvent, LastfmState> {
  LastfmBloc() : super(LastfmInitial()) {
    on<LastfmEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

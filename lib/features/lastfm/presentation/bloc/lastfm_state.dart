part of 'lastfm_bloc.dart';

abstract class LastfmState extends Equatable {
  const LastfmState();

  @override
  List<Object> get props => [];
}

class LastfmInitial extends LastfmState {}

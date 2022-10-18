import 'package:equatable/equatable.dart';

class TrackAttrEntity extends Equatable {
  final String nowPlaying;

  const TrackAttrEntity({
    required this.nowPlaying,
  });

  @override
  List<Object> get props => [nowPlaying];
}

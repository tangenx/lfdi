import 'package:equatable/equatable.dart';
import 'package:lfi/features/lastfm/domain/entities/track.dart';
import 'package:lfi/features/lastfm/domain/entities/user_attr.dart';

class RecentTracksEntity extends Equatable {
  final List<TrackEntity> track;
  final UserAttrEntity attr;

  const RecentTracksEntity({
    required this.track,
    required this.attr,
  });

  @override
  List<Object> get props => [track, attr];
}

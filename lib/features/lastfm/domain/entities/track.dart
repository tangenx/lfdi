import 'package:equatable/equatable.dart';
import 'package:lfi/features/lastfm/domain/entities/album.dart';
import 'package:lfi/features/lastfm/domain/entities/artist.dart';
import 'package:lfi/features/lastfm/domain/entities/image.dart';
import 'package:lfi/features/lastfm/domain/entities/track_attr.dart';

class TrackEntity extends Equatable {
  final ArtistEntity artist;
  final String streamable;
  final List<ImageEntity> image;
  final String mbid;
  final AlbumEntity album;
  final String name;
  final TrackAttrEntity? attr;
  final String url;

  const TrackEntity({
    required this.artist,
    required this.streamable,
    required this.image,
    required this.mbid,
    required this.album,
    required this.name,
    this.attr,
    required this.url,
  });

  @override
  List<Object?> get props {
    return [
      artist,
      streamable,
      image,
      mbid,
      album,
      name,
      attr,
      url,
    ];
  }
}

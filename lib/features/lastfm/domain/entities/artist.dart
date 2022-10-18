import 'package:equatable/equatable.dart';

class ArtistEntity extends Equatable {
  final String mbid;
  final String text;

  const ArtistEntity({
    required this.mbid,
    required this.text,
  });

  @override
  List<Object> get props => [mbid, text];
}

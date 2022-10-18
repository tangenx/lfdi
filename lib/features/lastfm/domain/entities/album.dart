import 'package:equatable/equatable.dart';

class AlbumEntity extends Equatable {
  final String mbid;
  final String text;

  const AlbumEntity({
    required this.mbid,
    required this.text,
  });

  @override
  List<Object> get props => [mbid, text];
}

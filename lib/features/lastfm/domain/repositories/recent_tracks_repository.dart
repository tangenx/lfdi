import 'package:dartz/dartz.dart';
import 'package:lfi/core/error/failure.dart';
import 'package:lfi/features/lastfm/domain/entities/recent_tracks.dart';

abstract class RecentTracksRepository {
  Future<Either<Failure, RecentTracksEntity>> getRecentTracks({
    String user,
    String apiKey,
  });
}

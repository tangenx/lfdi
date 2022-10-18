import 'package:dartz/dartz.dart';
import 'package:lfi/core/error/failure.dart';
import 'package:lfi/core/usecases/usecase.dart';
import 'package:lfi/features/lastfm/domain/entities/recent_tracks.dart';
import 'package:lfi/features/lastfm/domain/repositories/recent_tracks_repository.dart';
import 'package:lfi/features/lastfm/domain/usecases/lastfm_default_params.dart';

class GetRecentTracks extends Usecase<RecentTracksEntity, LastFmDefaultParams> {
  final RecentTracksRepository recentTracksRepository;

  GetRecentTracks(this.recentTracksRepository);

  @override
  Future<Either<Failure, RecentTracksEntity>> call(
    LastFmDefaultParams params,
  ) async {
    return await recentTracksRepository.getRecentTracks(
      user: params.user,
      apiKey: params.apiKey,
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class LastFmDefaultParams extends Equatable {
  final String user;
  final String apiKey;

  const LastFmDefaultParams({
    required this.user,
    required this.apiKey,
  });

  @override
  List<Object> get props => [user, apiKey];
}

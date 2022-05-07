import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/discord_websocket/websocket_manager.dart';
import 'package:lfdi/handlers/rpc.dart';
import 'package:lfdi/handlers/track_handler.dart';
import 'package:lfdi/main.dart';

class DiscordStatusPreview extends ConsumerStatefulWidget {
  const DiscordStatusPreview({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DiscordStatusPreview> createState() =>
      _DiscordStatusPreviewState();
}

class _DiscordStatusPreviewState extends ConsumerState<DiscordStatusPreview> {
  var box = Hive.box('lfdi');

  String trimText(String text) {
    if (text.length < 26) {
      return text;
    }

    return text.substring(0, 26) + '...';
  }

  Widget buildLastfmPreview(RPC rpc) {
    Track track = rpc.currentTrack;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLAYING A GAME',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: FluentTheme.of(context).brightness.isLight
                ? discordLightThemeHeadingColor
                : discordDarkThemeHeadingColor,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 66,
          child: Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Image(
                        image: ResizeImage(
                          NetworkImage(track.cover),
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircleAvatar(
                          backgroundColor:
                              FluentTheme.of(context).brightness.isLight
                                  ? discordLightBackgroundColor
                                  : discordDarkBackgroundColor,
                          radius: 60,
                          child: Image.asset(
                            'assets/images/lastfm discord smol.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    discordAppEnumToAppName[
                        discordAppIdToAppName[rpc.applicationId]]!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: FluentTheme.of(context).brightness.isLight
                          ? discordLightThemeLowerHeadingColor
                          : discordDarkThemeLowerHeadingColor,
                    ),
                  ),
                  Text(trimText(track.name)),
                  Text(trimText(track.artist)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGatewayPreview(DiscordWebSocketManager gateway) {
    Track track;

    if (gateway.currentTrack == null) {
      track = Track(
        artist: 'Some artist',
        album: 'Some album',
        name: 'Track name',
        playCount: 0,
        cover:
            'https://cdn.discordapp.com/app-assets/970447707602833458/971488024401690635.png',
        nowPlaying: false,
        duration: Duration.zero,
      );
    } else {
      track = gateway.currentTrack!;
    }

    String listeningToText;
    List<Widget> detailedViewWidgets = [];

    String playsText =
        '${track.playCount} plays ${track.playCount > 1 ? '(~${TrackHandler.getTotalListeningTime(track)})' : ''}';

    switch (gateway.presenceType!) {
      case GatewayPresenceType.listeningToMusic:
        listeningToText = 'music';

        detailedViewWidgets.add(Text(trimText(track.name)));
        detailedViewWidgets.add(Text(trimText(track.artist)));
        detailedViewWidgets.add(Text(playsText));

        break;
      case GatewayPresenceType.fullTrackInHeader:
        listeningToText = '${track.artist} - ${track.name}';

        detailedViewWidgets.add(Text(trimText(track.album)));
        detailedViewWidgets.add(Text(playsText));

        break;
      case GatewayPresenceType.trackNameInHeader:
        listeningToText = track.name;

        detailedViewWidgets.add(Text(trimText(track.artist)));
        detailedViewWidgets.add(Text(playsText));
        break;

      case GatewayPresenceType.musicAppInHeader:
        listeningToText = gateway.defaultMusicApp!;

        detailedViewWidgets.add(Text(trimText(track.name)));
        detailedViewWidgets.add(Text(trimText(track.artist)));
        detailedViewWidgets.add(Text(playsText));
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trimText('LISTENING TO ${listeningToText.toUpperCase()}'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: FluentTheme.of(context).brightness.isLight
                ? discordLightThemeHeadingColor
                : discordDarkThemeHeadingColor,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          height: 66,
          child: Row(
            children: [
              SizedBox(
                width: 66,
                height: 66,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Image(
                        image: ResizeImage(
                          NetworkImage(track.cover),
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircleAvatar(
                          backgroundColor:
                              FluentTheme.of(context).brightness.isLight
                                  ? discordLightBackgroundColor
                                  : discordDarkBackgroundColor,
                          radius: 60,
                          child: Image.network(
                            'https://i.imgur.com/1W6LRx1.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detailedViewWidgets,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rpc = ref.watch(rpcProvider);
    final gateway = ref.watch(discordGatewayProvider);
    gateway.addListener(
      name: 'onTrackChange',
      listener: () {
        setState(() {});
      },
    );
    rpc.addListener(
      name: 'onTrackChange',
      listener: () {
        setState(() {});
      },
    );

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).brightness.isLight
            ? discordLightBackgroundColor
            : discordDarkBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: box.get('priorUsing') == 'lastfm'
          ? buildLastfmPreview(rpc)
          : buildGatewayPreview(gateway),
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/handlers/track_handler.dart';

class DiscordStatusPreview extends StatelessWidget {
  final Track track;
  final String playingText;
  const DiscordStatusPreview({
    Key? key,
    required this.track,
    required this.playingText,
  }) : super(key: key);

  String trimTrackName() {
    if (track.name.length < 25) {
      return track.name;
    }

    return track.name.substring(0, 25) + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).brightness.isLight
            ? discordLightBackgroundColor
            : discordDarkBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                      playingText,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: FluentTheme.of(context).brightness.isLight
                            ? discordLightThemeLowerHeadingColor
                            : discordDarkThemeLowerHeadingColor,
                      ),
                    ),
                    Text(trimTrackName()),
                    Text(track.artist),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

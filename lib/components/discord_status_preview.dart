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
          const Text(
            'PLAYING A GAME',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
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
                        child: Image.network(
                          track.cover,
                          width: 60,
                          height: 60,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(track.name),
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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lfdi/components/window_buttons.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/pages/about.dart';
import 'package:lfdi/pages/discord.dart';
import 'package:lfdi/pages/settings.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WindowListener {
  int index = 0;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        // Why the fuck this is moving??
        automaticallyImplyLeading: false,
        leading: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: SizedBox(
            height: 20,
            width: 20,
            child: Image(
              image: AssetImage('assets/images/lastfm discord smol.png'),
            ),
          ),
        ),
        title: const DragToMoveArea(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              appTitle,
            ),
          ),
        ),
        actions: DragToMoveArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [Spacer(), WindowButtons()],
          ),
        ),
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        size: const NavigationPaneSize(
          openMaxWidth: 250,
          openMinWidth: 200,
          headerHeight: 0,
        ),
        displayMode: PaneDisplayMode.open,
        indicator: const StickyNavigationIndicator(),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Last.fm settings'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.preview_link),
            title: const Text('Discord Rich Presence'),
          ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const Icon(FluentIcons.info),
            title: const Text('About'),
          ),
        ],
      ),
      content: NavigationBody(
        index: index,
        children: const [
          SettingsPage(),
          DiscordRPCPage(),
          AboutPage(),
        ],
      ),
    );
  }

  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      windowManager.destroy();
    }
  }
}

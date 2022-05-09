import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lfdi/components/window_buttons.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/icons/lfdi_icons.dart';
import 'package:lfdi/main.dart';
import 'package:lfdi/pages/about.dart';
import 'package:lfdi/pages/gateway_settings.dart';
import 'package:lfdi/pages/log_console.dart';
import 'package:lfdi/pages/rpc_settings.dart';
import 'package:lfdi/pages/settings.dart';
import 'package:lfdi/utils/extract_windows_info.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int index = 0;

  @override
  void initState() {
    final ws = ref.read(discordGatewayProvider);
    ws.addListener(
      name: 'onReconnect_showSnackbar',
      listener: () {
        showSnackbar(
          context,
          const Snackbar(
            content: Text('Reconnecting to Gateway...'),
          ),
        );
      },
    );
    ws.addListener(
      name: 'onConnect_showSnackbar',
      listener: () {
        showSnackbar(
          context,
          const Snackbar(
            content: Text('Connected to Gateway.'),
          ),
        );
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WindowsVersionInfo windowsInfo = extractWindowsInfo();
    bool hideHeader = false;

    if (windowsInfo.ntVersion != null &&
        double.parse(windowsInfo.ntVersion!) < 10) {
      hideHeader = true;
    }

    return NavigationView(
      appBar: NavigationAppBar(
        // Why the fuck this is moving??
        automaticallyImplyLeading: false,
        height: hideHeader ? 10 : 50,
        leading: hideHeader
            ? null
            : const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Image(
                    image: AssetImage('assets/images/lastfm discord smol.png'),
                  ),
                ),
              ),
        title: hideHeader
            ? null
            : MoveWindow(
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    appTitle,
                  ),
                ),
              ),
        actions: hideHeader
            ? null
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MoveWindow(),
                  ),
                  const WindowButtons()
                ],
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
            icon: const Icon(LFDIIcons.lastfm),
            title: const Text('Last.fm settings'),
          ),
          PaneItem(
            icon: const SizedBox(
              width: 16,
              child: Icon(
                LFDIIcons.discord,
                size: 13,
              ),
            ),
            title: const Text('Discord Gateway settings'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.preview_link),
            title: const Text('Discord Rich Presence'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.content_feed),
            title: const Text('Log Console'),
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
          GatewaySettingsPage(),
          DiscordRPCPage(),
          LogConsole(),
          AboutPage(),
        ],
      ),
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';

class DiscordRPCPage extends StatelessWidget {
  const DiscordRPCPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Discord Rich Presence Settings'),
      ),
      children: const [Text('Coming soon...')],
    );
  }
}

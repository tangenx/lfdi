import 'package:fluent_ui/fluent_ui.dart';
import 'package:lfdi/components/settings_form.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: const PageHeader(
        title: Text('Last.fm settings'),
      ),
      children: const [SettingsForm()],
    );
  }
}

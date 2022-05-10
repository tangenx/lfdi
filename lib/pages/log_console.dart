import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:lfdi/constants.dart';
import 'package:lfdi/globals.dart';

class LogConsole extends StatefulWidget {
  const LogConsole({Key? key}) : super(key: key);

  @override
  State<LogConsole> createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole> {
  Timer? updateTimer;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> logMessages = [];

  @override
  void initState() {
    logMessages = logger.logMessages;
    updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        logMessages = logger.logMessages;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: const PageHeader(
        title: Text('Log Console'),
      ),
      content: logMessages.isEmpty
          ? const Center(
              child: Text('No logs yet ¯\\_(ツ)_/¯'),
            )
          : Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              height: 340,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: SelectableText.rich(
                  TextSpan(
                    children: logMessages
                        .map(
                          (e) => TextSpan(
                            text: e['message']! + '\n',
                            style: TextStyle(
                              color: logTypeToColor[e['type']],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
              // ListView.builder(
              //   controller: _scrollController,
              //   itemCount: logMessages.length,
              //   shrinkWrap: true,
              //   itemBuilder: (context, index) => SelectableText(
              //     logMessages[index]['message']!,
              //     style: TextStyle(
              //       color: logTypeToColor[logMessages[index]['type']],
              //       fontSize: 12,
              //     ),
              //   ),
              // ),
              ),
    );
  }
}

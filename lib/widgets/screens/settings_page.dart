export 'settings_page.dart';

import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        Text('Settings'),
        SizedBox(height: 20),
        Text('Fork me on GitHub'),
        SizedBox(height: 20),
        Text('GitHub: https://github.com/Rapougnac/SpotiDL'),
      ],
    );
  }
}

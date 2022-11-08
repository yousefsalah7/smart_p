import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:settings_ui/settings_ui.dart' as setteng;

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    /// Set to `true` to see the full possibilities of the iOS Developer Screen
    final bool runCupertinoApp = false;

    return MaterialApp(
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      title: 'Settings UI Demo',
      home: setteng.SettingsList(
        sections: [
          setteng.SettingsSection(
            title: Text('Common'),
            tiles: <setteng.SettingsTile>[
              setteng.SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text('English'),
              ),
              setteng.SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.format_paint),
                title: Text('Enable custom theme'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
